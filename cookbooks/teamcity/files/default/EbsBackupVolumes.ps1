<#
.SYNOPSIS
    Functions to do EBS snapshots.
#>

# Powershell 2.0
# Copyright (c) 2008-2011 RightScale, Inc, All Rights Reserved Worldwide.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$libDir = Split-Path $scriptDir

. "$libDir\rs\RsApiCallWithRetry.ps1"

function CommitSnapshot([string]$aws_id)
{
<#
.SYNOPSIS
    Commits snapshot.
.DESCRIPTION
    Adds tag committed=true by invoking update_ebs_snapshot.js API 1.0 call.
.PARAMETER aws_id
    AWS ID of the snapshot.
#>

    Write-Host "Updating snapshot $aws_id..."
    try
    {
        $response = RsApiCallWithRetry "update_ebs_snapshot.js" "PUT" "aws_id=$aws_id&commit_state=committed&api_version=1.0"
        $responseStm = $response.GetResponseStream()
        $responseReader = new-object System.IO.StreamReader($responseStm)
        $responseStr = $responseReader.ReadToEnd()

        Write-Debug "Response: $responseStr"
    }
    finally
    {
        if ($responseReader -ne $Null)
        {
            $responseReader.Close()
            $responseReader = $Null
        }
        if ($responseStm -ne $Null)
        {
            $responseStm.Close()
            $responseStm = $Null
        }
        if ($response -ne $Null)
        {
            $response.Close()
            $response = $Null
        }
    }
}

function EbsBackupVolumes($dataVolRoot, $dbLineageName = $env:DB_LINEAGE_NAME, [array]$dataVolDevices = @())
{
<#
.SYNOPSIS
    Performs backup by creating EBS snapshots of data volume.
    Simple and striped volumes are supported.
.DESCRIPTION
    This function creates EBS snapshots of data volume by invoking
    create_ebs_backup.js API 1.0 call. Uses VSS to guarantee consistency of
    files on data volume. Also performs cleanup of lineage backup with
    parameters passed via env variables (DB_BACKUP_KEEP_LAST,
    DB_BACKUP_KEEP_DAILY, etc).
.OUTPUTS
    $True if successful, throws exception if failed.
.PARAMETER dataVolRoot
    Drive letter of data volume (single char).
.PARAMETER dbLineageName
    Backups lineage name.
.PARAMETER dataVolDevices
    Array of device names that make up data volume (required for striped volume,
    could be omitted for simple volume). If omitted the device name is assumed
    to be xvdX, where X is drive letter (e.g xvdd for D:\, xvde for E:\, etc).
#>

    # check required inputs
    if (!$dbLineageName)
    {
        throw "Database lineage name is not specified."
    }

    Write-Host "Using lineage name $dbLineageName."

    # check optional inputs.
    $keepLast = $(if($env:DB_BACKUP_KEEP_LAST) { $env:DB_BACKUP_KEEP_LAST } else { 60 })
    $keepDaily = $(if($env:DB_BACKUP_KEEP_DAILY) { $env:DB_BACKUP_KEEP_DAILY } else { 14 })
    $keepWeekly = $(if($env:DB_BACKUP_KEEP_WEEKLY) { $env:DB_BACKUP_KEEP_WEEKLY } else { 6 })
    $keepMonthly = $(if($env:DB_BACKUP_KEEP_MONTHLY) { $env:DB_BACKUP_KEEP_MONTHLY } else { 12 })
    $keepYearly = $(if($env:DB_BACKUP_KEEP_YEARLY) { $env:DB_BACKUP_KEEP_YEARLY } else { 2 })

    $dataVolLower = $dataVolRoot.Substring(0,1).ToLower()
    $dataVolUpper = $dataVolRoot.Substring(0,1).ToUpper()

    $dataVolRoot = $dataVolLower+':\'
    Write-Host "Starting backup for $dataVolRoot"

    $alphaVssDllPath = "$env:rs_sandbox_home\RightScript\tools\AlphaVSS\AlphaVSS.Common.dll"

    Add-Type -path "$alphaVssDllPath"

    $oVSSImpl = [Alphaleonis.Win32.Vss.VssUtils]::LoadImplementation()

    $oVSS = $oVSSImpl.CreateVssBackupComponents()
    $oVSS.GetType().GetMethod("InitializeForBackup").Invoke($oVSS, @($Null))

    $oVSS.SetBackupState($False, $False, [Alphaleonis.Win32.Vss.VssBackupType]::Full, $False)

    $oVSS.StartSnapshotSet()
    $oVSS.AddToSnapshotSet($dataVolRoot)

    $async = $oVSS.PrepareForBackup()
    $async.Wait()

    if (!$dataVolDevices)
    {
        $dataVolDevices = @("xvd${dataVolLower}")
    }
    $dev = ($dataVolDevices) -join ','

    $drv = "$dataVolUpper"
    $dt = Get-Date -format yyyyMMddHHmmss
    $desc = "${env:EC2_INSTANCE_ID}-Vol-$drv-$dt"

    Write-Host "Creating snapshot..."
    $params = "lineage=$dbLineageName&devices=$dev&description=$desc&commit=explicit&api_version=1.0"
    $result = RsApiCallWithRetryJson "create_ebs_backup.js" "POST" $params
    Write-Debug "create_ebs_backup.js: result type - $($result.GetType().FullName)"
    Write-Host "Created snapshots: $result"

    $oVSS.AbortBackup()
    $oVSS.Dispose()
    $oVSS = $NULL

    foreach ($snapId in $result.aws_ids)
    {
        CommitSnapshot $snapId
    }

    Write-Host "Cleanup the stripe..."
    try
    {
        $params = "lineage=$dbLineageName&keep_last=$keepLast&dailies=$keepDaily&weeklies=$keepWeekly&monthlies=$keepMonthly&yearlies=$keepYearly&api_version=1.0"
        $response = RsApiCallWithRetry "cleanup_ebs_backups.js" "PUT" $params
        $responseStm = $response.GetResponseStream()
        $responseReader = new-object System.IO.StreamReader($responseStm)
        $responseStr = $responseReader.ReadToEnd()

        Write-Debug "Response: $responseStr"
    }
    finally
    {
        if ($responseReader -ne $Null)
        {
            $responseReader.Close()
            $responseReader = $Null
        }
        if ($responseStm -ne $Null)
        {
            $responseStm.Close()
            $responseStm = $Null
        }
        if ($response -ne $Null)
        {
            $response.Close()
            $response = $Null
        }
    }

    return $TRUE
}
