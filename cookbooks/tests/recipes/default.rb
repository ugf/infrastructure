rightscale_marker :begin

git = "\"#{ENV['PROGRAMFILES(X86)']}\\Git\\bin\\git\""

execute 'Downloading tests' do
  command "#{git} clone git://github.com/ugf/infrastructure_tests.git"
  cwd '/'
end

execute 'Checkout tests revision' do
  command "#{git} checkout #{node[:tests][:revision]}"
  cwd '/infrastructure_tests'
  not_if { node[:tests][:revision] == 'head' }
end

rightscale_marker :end


