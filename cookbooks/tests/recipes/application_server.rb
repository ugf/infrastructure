include_recipe 'tests::default'

rightscale_marker :begin

TAGS = '-t @application_server'
OUT = 'c:\temp\infrastructure_results.html'

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} #{TAGS} -f html -o #{OUT}"
  cwd '/'
end

rightscale_marker :end


