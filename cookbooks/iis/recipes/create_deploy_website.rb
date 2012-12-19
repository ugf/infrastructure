rightscale_marker :begin

Dir.mkdir(node[:powershell_scripts_dir]) unless File.exist?(node[:powershell_scripts_dir])

template "#{node[:powershell_scripts_dir]}/deploy_website.ps1" do
  source 'deploy_website.erb'
  variables(
    :administrator_password => node[:windows][:administrator_password]
  )
end

rightscale_marker :end