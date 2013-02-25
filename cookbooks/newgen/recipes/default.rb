class Chef::Resource
  include ConfigFiles
end

include_recipe 'newgen::download'

rightscale_marker :begin

execute 'Create logs folder' do
  command 'mkdir c:\logs'
  not_if { File.exist? 'c:\logs' }
end

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end

execute 'Grant access to certificate for Network Service' do
  command 'WinHttpCertCfg.exe -g -c LOCAL_MACHINE\MY -s "passivests" -a "NetworkService"'
  cwd '/Program Files (x86)/Windows Resource Kits/Tools'
end

powershell 'Copying websites' do
  parameters({
    'source' => "c:#{node[:binaries_directory].gsub('/', '\\')}",
    'target' => "c:#{node[:websites_directory].gsub('/', '\\')}"
  })
  script = <<-EOF

    if (test-path $env:target) { remove-item $env:target -recurse }
    new-item $env:target -type directory -force

    copy-item "$env:source\\main_website" "$env:target" -recurse -force
    copy-item "$env:source\\sts_website" "$env:target" -recurse -force
    copy-item "$env:source\\migration\\." "$env:target\\main_website\\bin"

  EOF
  source(script)
end

ruby_block 'Updating config files' do
  block do
    update_database_settings node[:websites_directory]
    update_website_settings
  end
end

powershell 'Deploying websites' do
  parameters({
    'POWERSHELL_SCRIPTS_DIR' => "c:#{node[:powershell_scripts_dir].gsub('/', '\\')}",
    'WEBSITES_DIRECTORY' => "c:#{node[:websites_directory].gsub('/', '\\')}"
  })
  script = <<-EOF
    Import-Module "$env:POWERSHELL_SCRIPTS_DIR\\deploy_website.ps1"

    Stop-Website -Name 'Default Web Site'
    Set-ItemProperty 'IIS:\\Sites\\Default Web Site' ServerAutoStart False

    deploy_website 'main website' 'main_website' "$env:WEBSITES_DIRECTORY\\main_website" ':80:' 'networkservice'
    deploy_website 'sts website' 'sts_website' "$env:WEBSITES_DIRECTORY\\sts_website" ':81:' 'networkservice'
  EOF
  source(script)
end

powershell 'Warming up websites' do
  script = <<-EOF
    foreach($port in @('80', '81')) {
      $req = [system.net.WebRequest]::Create("http://localhost:$port")

      try { $response = $req.GetResponse() }
      catch [system.net.WebException] { $response = $_.Exception.Response }

      $status = [int]$response.StatusCode
      write-output "$port $status"
      $Error.Clear()
    }
  EOF
  source(script)
end

rightscale_marker :end