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

ruby_block 'Copying websites' do
  block do
    FileUtils.mkdir_p(node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/main_website", node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/sts_website", node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/migration/.", "#{node[:websites_directory]}/main_website/bin")
  end
end

ruby_block 'Updating config files' do
  block { update_configs }
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