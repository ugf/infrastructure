rightscale_marker :begin

git = "\"#{ENV['PROGRAMFILES(X86)']}\\Git\\bin\\git\""
tests_directory = '/infrastructure_tests'

execute 'Removing previous clone' do
  command "rd /s /q \"#{tests_directory}\""
  cwd '/'
  only_if { File.exist?(tests_directory) }
end

execute 'Downloading tests' do
  command "#{git} clone git://github.com/ugf/infrastructure_tests.git"
  cwd '/'
end

execute 'Checkout tests revision' do
  command "#{git} checkout #{node[:tests][:revision]}"
  cwd tests_directory
  not_if { node[:tests][:revision] == 'head' }
end

execute 'Create output folder' do
  command 'mkdir c:\temp'
  not_if { File.exist? 'c:\temp' }
end

execute 'Bundle Install' do
  command 'bundle install'
  cwd "#{node[:tests_directory]}"
end

rightscale_marker :end


