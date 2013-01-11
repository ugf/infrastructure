rightscale_marker :begin

execute 'Setting RightLink login account' do
  command "sc config RightLink obj= .\\administrator password= #{node[:windows][:administrator_password]}"
end

execute 'Reboot' do
  command 'sc qc RightLink | find "SERVICE_START_NAME : .\administrator" || shutdown /r'
end

rightscale_marker :end