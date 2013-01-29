rightscale_marker :begin

execute 'Downloading tests' do
  command 'git clone git://github.com/ugf/infrastructure_tests.git'
  cwd '/'
end

rightscale_marker :end


