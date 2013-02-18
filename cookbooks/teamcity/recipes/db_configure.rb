rightscale_marker :begin

template 'd:\create_database.sql' do
  source 'create_database.erb'
  variables(
    :database_user => node[:teamcity][:database_user],
    :database_password => node[:teamcity][:database_password]
  )
end

windows_batch 'Create TeamCity database' do
  code 'sqlcmd -E -id:\create_database.sql'
end

template 'd:\create_console_login.sql' do
  source 'create_console_login.sql.erb'
  variables(
    :console_user => node[:teamcity][:console_user],
    :console_password => node[:teamcity][:console_password]
  )
end

windows_batch 'Create console login' do
  code 'sqlcmd -E -id:\create_console_login.sql'
end

rightscale_marker :end