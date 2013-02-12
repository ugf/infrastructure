include_recipe 'tests::default'

rightscale_marker :begin

ENV['elmah/database_user'] = node[:elmah][:database_user]
ENV['elmah/database_password'] = node[:elmah][:database_password]

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} --tags @logging_server"
  cwd '/'
end

rightscale_marker :end


