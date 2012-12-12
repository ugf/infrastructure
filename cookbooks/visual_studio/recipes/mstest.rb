rightscale_marker :begin

Dir.mkdir(node[:ruby_scripts_dir]) unless File.exist? node[:ruby_scripts_dir]

cookbook_file "#{node[:ruby_scripts_dir]}/UtilityFunctions.ps1" do
  source 'UtilityFunctions.ps1'
end

powershell 'downloading visual studio test framework' do
  parameters(
    {
      'AWS_ACCESS_KEY_ID' => node[:core][:aws_access_key_id],
      'AWS_SECRET_ACCESS_KEY' => node[:core][:aws_secret_access_key]
    }
  )
  script = <<-EOF
    $install_dir = join-path ${ENV:\PROGRAMFILES(X86)} "Microsoft Visual Studio 11.0"
    if (test-path $install_dir)
    {
       Write-Output "Visual Studio Test Framework already installed. Skipping installation."
       exit 0
    }

    if (test-path "c:\\vs2012\\vstf_testagent.exe")
    {
       Write-Output "Visual Studio Test Framework already downloaded."
       exit 0
    }

    if (test-path "c:\\installs\\vstf_testagent.zip")
    {
       Write-Output "Visual Studio Test Framework already downloaded."
       exit 0
    }

    $scripts_path = 'c:' + '#{node[:ruby_scripts_dir]}'.replace("/", "\\")

    # Load Utility Functions
    . "$scripts_path\\UtilityFunctions.ps1"

    # Load the AWS SDK for .NET assembly
    LoadAwsSDK

    if (Test-Path("c:\\installs")) {
      Write-Output "c:\\installs already created"
    }
    else {
      New-Item c:\\installs -type directory
    }

    cd c:\\installs

    Write-Output 'Start download'
    # Get the signed URL from S3 and download packages
    $packageUrl = getSignedUrl `
        -bucketName "ugfinfrastructure" `
        -key "vstf_testagent.zip" `
        -awsAccessKey "$env:AWS_ACCESS_KEY_ID" `
        -awsSecretKey "$env:AWS_SECRET_ACCESS_KEY"

    DownloadFile -url `"$packageUrl`" -threads 15

    Write-Output 'Unzip package'

    mkdir -force c:\\vs2012
    cmd /c "${env:\ProgramFiles(x86)}\\7-Zip\\7z.exe" x -y -oc:\\vs2012 -r "c:\\installs\\vstf_testagent.zip"
  EOF
  source(script)
end

powershell 'Installing Visual Studio Test Framework' do
  script = <<-EOF
    $install_dir = join-path ${ENV:\PROGRAMFILES(X86)} "Microsoft Visual Studio 11.0"
    if (test-path "c:\\VS2012\\log.txt")
    {
      Write-Output "VSTF is in a reboot cycle, let it finish on it's own."

      do {
        write-host 'Waiting for visual studio...'
        start-sleep 5
      }
      until ((Get-Content c:\\vs2012\\log.txt | Select-Object -last 1).Contains('Exit code: 0x0, restarting: No'))

      write-host 'Visual Studio successfully installed'

      exit 0
    }

    if (test-path $install_dir)
    {
       Write-Output "VSTF already installed. Skipping installation."
       exit 0
    }

    & "c:\\VS2012\\vstf_testagent.exe" "/noweb" "/full" "/log" "c:\\VS2012\\log.txt" "/quiet" "/forcerestart"
  EOF
  source(script)
end

rightscale_marker :end