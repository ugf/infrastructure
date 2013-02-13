include_recipe 'tests::default'

rightscale_marker :begin

TAGS = '-t @application_server'
OUT = '-f pretty -f html -o c:\temp\infrastructure_results.html'

execute 'Running tests' do
  command "cucumber #{node[:tests_directory]} #{TAGS} #{OUT}"
  cwd '/'
end

rightscale_marker :end


