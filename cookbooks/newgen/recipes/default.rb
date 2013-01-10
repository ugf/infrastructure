rightscale_marker :begin

require 'rake'

class Chef::Resource
  include ConfigFiles
end

include_recipe 'newgen::download'

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end

powershell 'asdfd' do
  parameters({
    'BINARIES_DIRECTORY' => "c:#{node[:binaries_directory].gsub('/', '\\')}",
    'WEBSITES_DIRECTORY' => "c:#{node[:websites_directory].gsub('/', '\\')}"
  })
  script = <<-EOF
    New-Item $env:WEBSITES_DIRECTORY -type directory -force
    Copy-Item "$env:BINARIES_DIRECTORY\\main_website" "$env:WEBSITES_DIRECTORY" -recurse
    Copy-Item "$env:BINARIES_DIRECTORY\\sts_website" "$env:WEBSITES_DIRECTORY" -recurse
    Copy-Item "$env:BINARIES_DIRECTORY\\migration\." "$env:WEBSITES_DIRECTORY\\main_website\\bin"
  EOF
  source(script)
end

ruby_block 'Updating config files' do
  block do
    update_website_settings
    update_database_settings
  end
end

powershell 'Deploying websites' do
  parameters({
    'POWERSHELL_SCRIPTS_DIR' => "c:#{node[:powershell_scripts_dir].gsub('/', '\\')}",
    'WEBSITES_DIRECTORY' => "c:#{node[:websites_directory].gsub('/', '\\')}"
  })
  script = <<-EOF
    Import-Module "$env:POWERSHELL_SCRIPTS_DIR\\deploy_website.ps1"

    deploy_website 'main website' 'main_website' "$env:WEBSITES_DIRECTORY\\main_website" ':55555:'
    deploy_website 'sts website' 'sts_website' "$env:WEBSITES_DIRECTORY\\sts_website" ':55556:'
  EOF
  source(script)
end

rightscale_marker :end