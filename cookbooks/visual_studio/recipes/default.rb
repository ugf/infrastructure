class Chef::Resource
  include DetectVagrant
end

class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

Dir.mkdir(node[:ruby_scripts_dir]) unless File.exist? node[:ruby_scripts_dir]

cookbook_file "#{node[:ruby_scripts_dir]}/UtilityFunctions.ps1" do
  source 'UtilityFunctions.ps1'
end

powershell 'downloading visual studio via s3' do
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
       Write-Output "VS2012 already installed. Skipping installation."
       exit 0
    }

    if (test-path "c:\\vs2012\\VS_Premium.exe")
    {
       Write-Output "VS2012 already downloaded."
       exit 0
    }

    if (test-path "c:\\installs\\VS_2012_Premium.zip")
    {
       Write-Output "VS2012 already downloaded."
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
        -key "VS_2012_Premium.zip" `
        -awsAccessKey "$env:AWS_ACCESS_KEY_ID" `
        -awsSecretKey "$env:AWS_SECRET_ACCESS_KEY"

    DownloadFile -url `"$packageUrl`" -threads 15

    Write-Output 'Unzip package'

    mkdir -force c:\\vs2012
    cmd /c "${env:\ProgramFiles(x86)}\\7-Zip\\7z.exe" x -y -oc:\\vs2012 -r "c:\\installs\\VS_2012_Premium.zip"
  EOF
  source(script)
  not_if { node[:core][:aws_access_key_id].empty? || node[:core][:aws_secret_access_key].empty? }
end

ruby_block 'downloading visual studio via denver2' do
  block do
    Dir.mkdir('c:\installs') unless File.exist?('c:\installs')

    Chef::Log.info('net use on share')
    `net use \\\\denver2\\groups /user:devcorp\\svc.tv teamv`

    Chef::Log.info('copying files')
    `xcopy "\\\\denver2\\groups\\Build and Deployment\\newgen\\repository\\ugfinfrastructure\\VS_2012_Premium.zip" c:\\installs`

    Chef::Log.info('net use delete')
    `net use \\\\denver2\\groups /delete`
  end
  only_if { node[:core][:aws_access_key_id].empty? && node[:core][:aws_secret_access_key].empty? }
  not_if { File.exist?('/installs/VS_2012_Premium.zip')}
end

windows_zipfile '/VS2012' do
  source '/installs/VS_2012_Premium.zip'
  action :unzip
  not_if { File.exist?('/VS2012') }
end

powershell 'Installing visual studio' do
  script = <<-EOF
    $install_dir = join-path ${ENV:\PROGRAMFILES(X86)} "Microsoft Visual Studio 11.0"
    if (test-path "c:\\VS2012\\log.txt")
    {
      Write-Output "VS2012 is in a reboot cycle, let it finish on it's own."

      do {
        write-host 'Waiting for visual studio...'
        start-sleep 5
      }
      until ((Get-Content c:\\VS2012\\log.txt | Select-Object -last 1).Contains('Exit code: 0x0, restarting: No'))

      write-host 'Visual Studio successfully installed'

      rm c:\\VS2012\\log.txt

      exit 0
    }

    if (test-path $install_dir)
    {
       Write-Output "VS2012 already installed. Skipping installation."
       exit 0
    }

    & "c:\\VS2012\\vs_premium.exe" "/noweb" "/full" "/log" "c:\\VS2012\\log.txt" "/quiet" "/forcerestart"
  EOF
  source(script)
end

emit_marker :end