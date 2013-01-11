rightscale_marker :begin

execute 'Setting RightLink login account' do
  command <<-EOF
    sc config RightLink obj= .\\administrator password= #{node[:windows][:administrator_password]}
    shutdown /r
  EOF
end

rightscale_marker :end