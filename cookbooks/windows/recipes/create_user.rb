rightscale_marker :begin

user = node[:windows][:new_user_name]
pass = node[:windows][:new_user_password]

def missing?(cmd, txt)
  `#{cmd} | find "#{txt}"`.empty?
end

execute "Create #{user} user" do
  command "net user #{user} #{pass} /add /expires:never"
  only_if { missing? "net user #{user}", user }
end

rightscale_marker :end