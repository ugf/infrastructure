rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/disconnect.rb" do
  source 'scripts/disconnect.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name],
    :prefix => node[:load_balancer][:prefix],
    :instance_backend_name => node[:load_balancer][:backend_name]
  )
end

if node[:platform] == "ubuntu"
  bash 'Disconnecting instance from haproxy' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/disconnect.rb
    EOF
    only_if { node[:load_balancer][:should_register_with_lb] == 'true' }
  end
else
  powershell 'Disconnecting instance from haproxy' do
    source("ruby #{node[:ruby_scripts_dir]}/disconnect.rb")
    only_if { node[:load_balancer][:should_register_with_lb] == 'true' }
  end
end

rightscale_marker :end