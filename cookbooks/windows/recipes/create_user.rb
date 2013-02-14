rightscale_marker :begin

user = node[:windows][:new_user_name]
pass = node[:windows][:new_user_password]

execute "Create #{user} user" do
  command "net user #{user} #{pass} /add /expires:never"
  only_if "`net user #{user} | find \"#{user}\"`.empty?"
end

rightscale_marker :end