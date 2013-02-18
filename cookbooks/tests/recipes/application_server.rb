include_recipe 'tests::default'

rightscale_marker :begin

TAGS = '-t @application_server'
OUT = '-f pretty -f html -o c:\temp\infrastructure_results.html'

ENV['route53/ip'] = node[:route53][:ip]
ENV['route53/prefix'] = node[:route53][:prefix]
ENV['route53/domain'] = node[:route53][:domain]

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} #{TAGS} #{OUT}"
  cwd '/'
end

rightscale_marker :end


