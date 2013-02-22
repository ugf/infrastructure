include_recipe 'tests::default'

rightscale_marker :begin

ENV['elmah/logging_server'] = node[:elmah][:logging_server]
ENV['elmah/database_user'] = node[:elmah][:database_user]
ENV['elmah/database_password'] = node[:elmah][:database_password]

ENV['route53/ip'] = node[:route53][:ip]
ENV['route53/prefix'] = node[:route53][:prefix]
ENV['route53/domain'] = node[:route53][:domain]

ENV['windows/new_user_name'] = node[:windows][:new_user_name]

ENV['newgen/database_server'] = node[:newgen][:database_server]
ENV['newgen/database_password'] = node[:newgen][:database_password]
ENV['newgen/database_user'] = node[:newgen][:database_user]

TAGS = '-t @application_server'
OUT = '-f pretty -f html -o c:\temp\infrastructure_results.html'

execute 'Running tests' do
  command "bundle exec cucumber . #{TAGS} #{OUT}"
  cwd "#{node[:tests_directory]}"
end

rightscale_marker :end


