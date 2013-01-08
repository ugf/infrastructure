rightscale_marker :begin

class Chef::Resource
  include ConfigFiles
end

require 'rake'

include_recipe 'newgen::download'

ruby_block 'Copying websites' do
  block do
    FileUtils.mkdir_p(node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/main_website", node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/migration/.", "#{node[:websites_directory]}/main_website/bin")
  end
end

ruby_block 'Updating config files' do
  block do
    update_configs
  end
end

execute 'Running migrate' do
  command "migrate.ci.with.username.bat #{node[:newgen][:database_server]} #{node[:newgen][:database_user]} #{node[:newgen][:database_password]}"
  cwd "#{node[:websites_directory]}/main_website/bin"
end

rightscale_marker :end