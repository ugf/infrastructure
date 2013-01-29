rightscale_marker :begin

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]}"
  cwd '/'
end

rightscale_marker :end


