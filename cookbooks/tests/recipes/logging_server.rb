include_recipe 'tests::default'

rightscale_marker :begin

TAGS = '-t @logging_server'
OUT = '-f pretty -f html -o c:\temp\infrastructure_results.html'

ENV['elmah/database_user'] = node[:elmah][:database_user]
ENV['elmah/database_password'] = node[:elmah][:database_password]

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} #{TAGS} #{OUT}"
  cwd '/'
end

rightscale_marker :end


