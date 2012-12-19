rightscale_marker :begin

template "#{node[:powershell_scripts_dir]}/deploy_website.ps1" do
  source 'deploy_website.erb'
  variables(
    :administrator_password => node[:windows][:administrator_password]
  )
end

rightscale_marker :end