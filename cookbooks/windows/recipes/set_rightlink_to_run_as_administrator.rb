rightscale_marker :begin

execute 'Setting RightLink login account' do
  command "sc config RightLink obj= .\\administrator password= #{node[:windows][:administrator_password]}"
end

rightscale_marker :end