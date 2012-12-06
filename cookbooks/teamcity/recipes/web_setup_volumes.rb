rightscale_marker :begin

lib_directory = "#{ENV['rs_sandbox_home']}/RightScript/lib/overrides"
Dir.mkdir(lib_directory) unless File.exist?(lib_directory)

cookbook_file "#{lib_directory}/EbsRestoreVolumes.ps1" do
  source 'EbsRestoreVolumes.ps1'
end

powershell('Setup volumes') do
  parameters(
    {
      'DATA_VOLUME_SIZE' => node[:teamcity][:data_volume_size],
      'FORCE_CREATE_VOLUMES' => node[:teamcity][:force_create_volumes],
      'LINEAGE_NAME' => node[:teamcity][:lineage_name],
      'RESTORE_TIMESTAMP' => '',
      'AWS_ACCESS_KEY_ID' => node[:core][:aws_access_key_id],
      'AWS_SECRET_ACCESS_KEY' => node[:core][:aws_secret_access_key]
    }
  )
  script = <<-EOF
# Stop and fail script when a command fails.
$errorActionPreference = "Stop"

# load library functions
$rsLibDstDirPath = "$env:rs_sandbox_home\\RightScript\\lib"
. "$rsLibDstDirPath\\tools\\ResolveError.ps1"
. "$rsLibDstDirPath\\tools\\Checks.ps1"
. "$rsLibDstDirPath\\tools\\RepartitionDisk.ps1"
. "$rsLibDstDirPath\\tools\\Text.ps1"
. "$rsLibDstDirPath\\tools\\ExtractReturn.ps1"
. "$rsLibDstDirPath\\ros\\Ros.ps1"
. "$rsLibDstDirPath\\ros\\RosBackups.ps1"
. "$rsLibDstDirPath\\overrides\\EbsRestoreVolumes.ps1"
. "$rsLibDstDirPath\\ebs\\EbsCreateAttachVolume.ps1"

# Helper function to create env variables
function SetDrivesEnvVars($dataLetter, $dataDevices)
{
    $dataDevices = $dataDevices -join ','

    Write-Host "Setting environment variables:"
    [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $dataLetter, "Machine")
    [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $dataLetter, "Process")
    [Environment]::SetEnvironmentVariable("DATA_DEVICES", $dataDevices, "Machine")
    Write-Host "RS_SQLS_DATA_VOLUME=${dataLetter}"
    Write-Host "DATA_DEVICES=${dataDevices}"
}

try
{
    $dataVolExists = $env:RS_SQLS_DATA_VOLUME -and (Test-Path "${env:RS_SQLS_DATA_VOLUME}:\")
    if ($dataVolExists)
    {
        Write-Host "Skipping: data volume already exists."
        exit 0
    }

    # Force create volumes if mirror (databases to be imported from principal or specific input is set)
    if ($env:FORCE_CREATE_VOLUMES -eq 'True')
    {
        Write-Host "FORCE_CREATE_VOLUMES is set to True - skipping restore and creating new volumes from scratch."
        $forceCreateVolumes = $True
    }

    $dataDriveLetter = 'D'
    $lineageName = $env:LINEAGE_NAME
    $timestamp = $env:RESTORE_TIMESTAMP

    if (!$forceCreateVolumes -and $lineageName)
    {
        Write-Host "Trying to restore volumes from EBS snapshots..."
        EbsRestoreVolumes $lineageName $timestamp
    }

    # Create volumes if not restored
    if (!$env:RS_SQLS_DATA_VOLUME)
    {
        Write-Host "Creating new data volume..."
        CheckInputInt 'DATA_VOLUME_SIZE' $False 1 | Out-Null

        write-host 'Creating volume via EbsCreateAttachVolume'
        EbsCreateAttachVolume $dataDriveLetter $env:DATA_VOLUME_SIZE
        $dataDevices = "xvd${dataDriveLetter}".ToLower()

        SetDrivesEnvVars $dataDriveLetter $dataDevices
    }
    $error.Clear()
}
catch
{
    ResolveError
    exit 1
}
  EOF
  source(script)
end

rightscale_marker :end