rightscale_marker :begin

lib_directory = "#{ENV['rs_sandbox_home']}/RightScript/lib/overrides"
Dir.mkdir(lib_directory) unless File.exist?(lib_directory)

cookbook_file "#{lib_directory}/EbsBackupVolumes.ps1" do
  source 'EbsBackupVolumes.ps1'
end

powershell('Backup volumes') do
  parameters({ 'LINEAGE_NAME' => node[:teamcity][:lineage_name] })
  script = <<-EOF
    $errorActionPreference="Stop"

    $rsLibDstDirPath = "$env:rs_sandbox_home\\RightScript\\lib"
    . "$rsLibDstDirPath\\tools\\ResolveError.ps1"
    . "$rsLibDstDirPath\\overrides\\EbsBackupVolumes.ps1"

    try
    {
        if (!(Test-Path "${env:RS_SQLS_DATA_VOLUME}:\"))
        {
            Write "Volume not found - nothing to backup. Exit silently."
            exit 0
        }

        Write-Host "Backup method is Snapshots."
        $dataDevices = $(if ($env:RS_SQLS_DATA_DEVICES) { ([string]$env:RS_SQLS_DATA_DEVICES).Split(',') } else { @() })

        # using defaults for DB_BACKUP_KEEP_* specified in C:\Program Files (x86)\RightScale\RightLink\sandbox\RightScript\lib\ebs\EbsBackupVolumes.ps1
        EbsBackupVolumes $env:RS_SQLS_DATA_VOLUME $env:LINEAGE_NAME $dataDevices
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