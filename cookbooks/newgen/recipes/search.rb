rightscale_marker :begin

require 'rake'

ruby_block 'Copying websites' do
  block do
    FileUtils.mkdir_p(node[:migration_directory])
    FileUtils.cp_r("#{node[:websites_directory]}/main_website/bin/.", node[:migration_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/migration/.", node[:migration_directory])
  end
end

ruby_block 'Updating config files' do
  block { update_database_settings node[:migration_directory] }
end

execute 'Running search migrate' do
  command "migrate.ci.with.username.search.bat #{node[:newgen][:database_server]} #{node[:newgen][:database_user]} #{node[:newgen][:database_password]}"
  cwd node[:migration_directory]
end

rightscale_marker :end