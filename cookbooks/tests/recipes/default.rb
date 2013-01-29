rightscale_marker :begin

execute 'Downloading tests' do
  command "\"#{ENV['PROGRAMFILES(X86)']}\\Git\\bin\\git\" clone git://github.com/ugf/infrastructure_tests.git"
  cwd '/'
end

rightscale_marker :end


