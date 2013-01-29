rightscale_marker :begin

features_directory = node[:features_directory]
repo_directory = '/tests_repository'

Dir.mkdir(features_directory) unless File.exist?(features_directory)

Dir.mkdir(repo_directory) unless File.exist?(repo_directory)

deploy repo_directory do
  repo 'git://github.com/ugf/chef_examples.git'
  revision 'HEAD' # or "HEAD" or "TAG_for_1.0" or (subversion) "1234"
  #user 'administrator'
  #enable_submodules true
  #migrate true
  #migration_command "rake db:migrate"
  #environment "RAILS_ENV" => "production", "OTHER_ENV" => "foo"
  shallow_clone true
  action :deploy # or :rollback
  #restart_command "touch tmp/restart.txt"
  git_ssh_wrapper "wrap-ssh4git.sh"
  scm_provider Chef::Provider::Git # is the default, for svn: Chef::Provider::Subversion
end

template "#{features_directory}/mstest.feature" do
  source 'features/mstest.feature.erb'
end

Dir.mkdir("#{features_directory}/step_definitions") unless File.exist?("#{features_directory}/step_definitions")

template "#{features_directory}/step_definitions/file_system.rb" do
  source 'features/step_definitions/file_system.rb.erb'
end

execute 'Running tests' do
  command "cucumber #{features_directory}"
  cwd '/'
end

rightscale_marker :end
