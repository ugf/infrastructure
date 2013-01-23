rightscale_marker :begin

inputs = "#{node[:ruby_scripts_dir]}/instance_inputs.json"

template inputs do
  source 'instance_inputs.json.erb'
  variables(
    :instance_backend_name => node[:load_balancer][:backend_name],
    :instance_ip => node[:load_balancer][:server_ip]
  )
end

command = "rs_run_recipe --name \"load_balancer::disconnect_instance\" -r \"lb:prefix=#{node[:load_balancer][:prefix]}\" --json #{inputs} --verbose"

if node[:load_balancer][:should_register_with_lb] == 'true'
  if node[:platform] == "ubuntu"
    bash('Disconnecting instance') { code command }
  else
    powershell('Disconnecting instance') { source command }
  end
end

rightscale_marker :end