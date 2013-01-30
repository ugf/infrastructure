include_recipe 'tests::default'

rightscale_marker :begin

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} --tags @application_server"
  cwd '/'
end

rightscale_marker :end


