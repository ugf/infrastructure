<#
.SYNOPSIS
    Function to restore EBS volumes from snapshots.
#>


# Powershell 2.0
# Copyright (c) 2008-2011 RightScale, Inc, All Rights Reserved Worldwide.

# Stop and fail script when a command fails
$ErrorActionPreference="Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$libDir = Split-Path $scriptDir

. "$libDir\tools\ExtractReturn.ps1"
. "$libDir\rs\RsApiCallWithRetry.ps1"
. "$libDir\aws\EC2.ps1"
. "$libDir\ebs\EbsVolumeInfo.ps1"
. "$libDir\win\Version.ps1"

function EbsRestoreVolumes($dbLineageName, $timestamp = '')
{
<#
.SYNOPSIS
    Restores data and log volumes from EBS snapshots. Supports simple and
    striped volumes.
.PARAMETER dbLineageName
    Name of the backup lineage to restore from.
.PARAMETER timestamp
    Timestamp of the specific backup to restore from (optional). Restores from
    the most recent backup if omitted.
#>

    try
    {
        $params = "lineage=$dbLineageName&api_version=1.0"
        if ($timestamp)
        {
            $params += "&timestamp=$timestamp"
        }
        $ebsSnapshots = RsApiCallWithRetryJson "find_latest_ebs_backup.js" "GET" $params
    }
    catch
    {
        Write-Host $_.Exception.Message
        Write-Host "Unable to find latest snapshot in EBS stripe $dbLineageName."
        Write-Host "Please check if the lineage name is correct and the status of the snapshot(s) is completed (snapshotting a large volume could take several hours)."
        return $False
    }

    $error = $ebsSnapshots | Where-Object { $_['error'] }
    if ($error)
    {
        Write-Host "Unable to find latest snapshot in EBS stripe $dbLineageName."
        Write-Host "Please check if the lineage name is correct and the status of the snapshot(s) is completed (snapshotting a large volume could take several hours)."
        return $False
    }

    # Don't automatically mount new volumes
    "automount disable" | diskpart

    $snapCount = $ebsSnapshots.Count
    $numberStripes = 1
    Write-Host "Found $snapCount snapshots in the backup"

    # Start diskpart to make sure new volume will be the last one by index
    # See Windows volume numbering trick - http://support.microsoft.com/kb/937252
    Start-Process diskpart

    for($snapIndex = 1; $snapIndex -le $snapCount; $snapIndex++)
    {
        # Search for appropriate snapshot in snapshot set
        $snap = $ebsSnapshots | Where-Object { $_['position'] -eq $snapIndex }
        Write-Host "Processing snapshot ${snapIndex}: $snap"

        $aws_id = $snap['aws_id']
        $device = $snap['device'].ToLower()
        if ((1 -eq $snapIndex) -or ($numberStripes+1 -eq $snapIndex))
        {
            # Extract drive letter from first snapshot of the volume
            $devices = $device
            $driveLetter = [char]::ToUpper($device[3])
            $drive = $driveLetter+":"
            $drivePath = "${driveLetter}:\"

            if (Test-Path $drivePath)
            {
                throw "Disk $drivePath already exists. Unable to restore from snapshot."
            }
        }
        else
        {
            $devices += ",${device}"
        }

        # Create and attach volume
        $nameIndex = $(if ($snapIndex -le $numberStripes) { $snapIndex } else { $snapIndex-$numberStripes })
        $volumeName = $(if (1 -eq $numberStripes) { "${env:EC2_INSTANCE_ID}-Vol-${driveLetter}" } else { "${env:EC2_INSTANCE_ID}-Vol-${driveLetter}-Stripe-${nameIndex}" })
        $ebsVolume = RsApiCallWithRetryJson "create_ebs_volume_from_snap.js" "POST" "aws_id=$aws_id&nickname=${volumeName}&api_version=1.0"
        $vol_id = $ebsVolume['aws_id']

        EbsWaitForVolumeStatus $vol_id 'available'

        $drives = gwmi Win32_diskdrive
        $oldDriveCount = $(if ($drives -is [system.array]) { $drives.Count } else { 1 })
        Write-Host "Number of disks: $oldDriveCount"

        $volumes = gwmi Win32_volume
        $oldVolCount = $(if ($volumes -is [system.array]) { $volumes.Count } else { 1 })
        Write-Host "Number of volumes: $oldVolCount"

        Write-Host "Attaching EBS volume..."
        $attachedVolume = RsApiCallWithRetryJson "attach_ebs_volume.js" "PUT" "aws_id=$vol_id&device=$device&api_version=1.0"

        EbsWaitForVolumeStatus $vol_id 'in-use'

        do
        {
            Start-Sleep -s 15
            $drives = gwmi Win32_diskdrive
        }
        while ($drives.Count -le $oldDriveCount)

        if (-not (IsServer2003))
        {
            # Get disk location path and store in env
            $detailName = $(if(IsServer2008R2) { 'Location Path' } else { 'LUN ID' })
            $locPath = "select disk=$oldDriveCount `n detail disk" | diskpart | Where-Object { $_.StartsWith($detailName) }
            # Now $locPath is string like 'Location Path : PCIROOT(0)#PCI(1F02)#ATA(C00T00L00)' on 2008R2
            $locPath = $locPath.SubString($locPath.LastIndexOf(':')+1).Trim()
            $devSuffix = $device.Replace('/', '').ToUpper()
            Write-Debug "Setting env variable RS_DISK_LOC_${devSuffix} to '$locPath'"
            [Environment]::SetEnvironmentVariable("RS_DISK_LOC_${devSuffix}", $locPath, "Machine")
            [Environment]::SetEnvironmentVariable("RS_DISK_LOC_${devSuffix}", $locPath, "Process")
        }

        $osVersionMajor = (((Get-WmiObject Win32_operatingsystem).version).ToString()).Split('.')[0]
        if ($osVersionMajor -eq "6")
        {
            $script = @"
select disk $oldDriveCount
online disk
attributes disk clear readonly
"@
            Write-Host "Running diskpart:`n$script"
            $script | diskpart

            if (1 -eq $numberStripes)
            {
                do
                {
                    Start-Sleep -s 5
                    $volumes = gwmi Win32_volume
                }
                while ($volumes.Count -le $oldVolCount)

                $script += @"
`nselect volume $oldVolCount
online volume
attributes volume clear readonly
"@

                Write-Host "Running diskpart:`n$script"
                $script | diskpart
            }
        }

        if (($snapIndex -eq $numberStripes) -or ($snapIndex -eq $snapCount))
        {
            # Last disk in the volume set - setup regular or striped volume
            if (1 -lt $numberStripes)
            {
                # Import striped volume
                $script = @"
select disk $oldDriveCount
import noerr
"@
                $script | diskpart

                # Wait for the new volume to appear
                do
                {
                    Start-Sleep -s 5
                    $volumes = gwmi Win32_volume
                }
                while ($volumes.Count -le $oldVolCount)
            }


            # Enumerate all volumes to find newly created one (no better way because RS API doesn't return DeviceID)
            $volumes = gwmi Win32_volume | where {$_.BootVolume -ne $True -and $_.SystemVolume -ne $True}
            foreach ($volume in $volumes)
            {
                if (!$volume.DriveLetter)
                {
                    mountvol $drive $volume.DeviceID
                    # volume mounted - break foreach loop
                    break
                }
            }

            If ($snapIndex -eq $numberStripes)
            {
                # Data volume
                [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $driveLetter, "Machine")
                [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $driveLetter, "Process")
                [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_DEVICES", $devices, "Machine")
                [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_DEVICES", $devices, "Process")
            }
            ElseIf ($snapIndex -eq $snapCount)
            {
                # Logs volume
                [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_VOLUME", $driveLetter, "Machine")
                [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_VOLUME", $driveLetter, "Process")
                [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_DEVICES", $devices, "Machine")
                [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_DEVICES", $devices, "Process")
            }
        }
    }

    Stop-Process -Name diskpart -Force
}

function EbsGetLatestLineage($lineage1, $lineage2,
    [string]$accessKeyId = $env:AWS_ACCESS_KEY_ID,
    [string]$secretAccessKey = $env:AWS_SECRET_ACCESS_KEY)
{
<#
.SYNOPSIS
    Function to compare 2 backup lineages to determine which one has the most
    recent backup.
.OUTPUTS
    Name of the lineage which has the most recent backup or empty string if
    bith lineages are empty.
.PARAMETER lineage1
    Name of the first lineage to compare.
.PARAMETER lineage2
    Name of the second lineage to compare.
.PARAMETER accessKeyId
    The Access Key ID used to authenticate requests to AWS services.
    Not required parameter, by default value of AWS_ACCESS_KEY_ID env variable is used.
.PARAMETER secretAccessKey
    The Secret Access Key used to authenticate your requests to AWS services.
    Not required parameter, by default value of AWS_ACCESS_KEY_ID env variable is used.
#>

    try {
        $snaps1 = RsApiCallWithRetryJson "find_latest_ebs_backup.js" "GET" "lineage=$lineage1&api_version=1.0"
    } catch {
        Write-Host $_.Exception.Message
        Write-Host "Unable to find latest snapshot in EBS stripe $lineage1."
        $snaps1 = $Null
    }

    try {
        $snaps2 = RsApiCallWithRetryJson "find_latest_ebs_backup.js" "GET" "lineage=$lineage2&api_version=1.0"
    } catch {
        Write-Host $_.Exception.Message
        Write-Host "Unable to find latest snapshot in EBS stripe $lineage2."
        $snaps2 = $Null
    }

    $snap1_id = ""
    if ($snaps1)
    {
        foreach ($snap in $snaps1) {
            if ($snap['error']) {
                Write-Host $snap['error']
                Write-Host "Unable to find latest snapshot in EBS stripe $lineage1."
                break
            }
            if ($snap['position'] -eq 1)
            {
                $snap1_id = $snap['aws_id']
                Write-Host "Snapshot $snap1_id is found for $lineage1."
                break
            }
        }
    }

    $snap2_id = ""
    if ($snaps2)
    {
        foreach ($snap in $snaps2) {
            if ($snap['error']) {
                Write-Host $snap['error']
                Write-Host "Unable to find latest snapshot in EBS stripe $lineage2."
                break
            }
            if ($snap['position'] -eq 1)
            {
                $snap2_id = $snap['aws_id']
                Write-Host "Snapshot $snap2_id is found for $lineage2."
                break
            }
        }
    }

    if ($snap1_id -and $snap2_id)
    {
        $i1 = GetSnapshotInfoById $snap1_id $accessKeyId $secretAccessKey | ExtractReturn
        $i2 = GetSnapshotInfoById $snap2_id $accessKeyId $secretAccessKey | ExtractReturn

        if ($i1 -and $i2)
        {
            return $( if ($i1.StartTime -lt $i2.StartTime) { $lineage2 } else { $lineage1 } )
        }
        else
        {
            return $( if ($i1) { $lineage1 } elseif ($i2) { $lineage2 } else { "" })
        }
    }
    else
    {
        return $( if ($snap1_id) { $lineage1 } elseif ($snap2_id) { $lineage2 } else { "" })
    }
}
