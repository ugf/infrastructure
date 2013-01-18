rightscale_marker :begin

class Chef::Resource
  include ConfigFiles
end

include_recipe 'newgen::download'

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
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
    update_website_settings
    update_database_settings node[:websites_directory]
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

    deploy_website 'main website' 'main_website' "$env:WEBSITES_DIRECTORY\\main_website" ':80:'
    deploy_website 'sts website' 'sts_website' "$env:WEBSITES_DIRECTORY\\sts_website" ':81:'
  EOF
  source(script)
end

rightscale_marker :end