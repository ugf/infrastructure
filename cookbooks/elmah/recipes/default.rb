rightscale_marker :begin

template "c:\\create_database.sql" do
  source 'create_database.sql.erb'
  variables(
    :database_user => node[:elmah][:database_user],
    :database_password => node[:elmah][:database_password]
  )
end

execute 'Create elmah database' do
  command "sqlcmd -E -ic:\\create_database.sql"
end

template "c:\\setup_database.sql" do
  source 'setup_database.sql.erb'
end

execute 'Setup elmah database' do
  command "sqlcmd -E -ic:\\setup_database.sql"
end

rightscale_marker :end