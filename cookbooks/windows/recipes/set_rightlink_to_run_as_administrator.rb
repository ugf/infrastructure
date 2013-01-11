rightscale_marker :begin

windows_reboot 60 do
  action :nothing
end

execute 'Setting RightLink login account' do
  command "sc config RightLink obj= .\\administrator password= #{node[:windows][:administrator_password]}"
  notifies :request, 'windows_reboot[60]'
end

rightscale_marker :end