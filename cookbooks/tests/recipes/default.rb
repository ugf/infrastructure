rightscale_marker :begin

execute 'Downloading tests' do
  command <<-EOF
    "#{ENV['PROGRAMFILES(X86)']}\\Git\\bin\\git" clone git://github.com/ugf/infrastructure_tests.git
    cd 'infrastructure_tests'
    git checkout #{node[:tests][:revision]}
EOF
  cwd '/'
end

rightscale_marker :end


