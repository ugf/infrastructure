rightscale_marker :begin

Dir.mkdir(node[:ruby_scripts_dir]) unless File.exist? node[:ruby_scripts_dir]

['get_signed_s3_url.ps1', 'UtilityFunctions.ps1'].each do |file|
  cookbook_file "#{node[:ruby_scripts_dir]}/#{file}" do
    source file
  end
end

powershell 'downloading visual studio' do
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

    mkdir -force c:\vs2012
    cmd /c "${env:\ProgramFiles(x86)}\\7-Zip\\7z.exe" x -y -oc:\vs2012 -r "c:\\installs\\VS_2012_Premium.zip"
  EOF
  source(script)
end

rightscale_marker :end