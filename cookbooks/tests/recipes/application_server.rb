rightscale_marker :begin

features_directory = node[:features_directory]
repo_directory = '/tests_repository'

Dir.mkdir(features_directory) unless File.exist?(features_directory)

Dir.mkdir(repo_directory) unless File.exist?(repo_directory)

execute 'Downloading tests' do
  command 'git clone git://github.com/ugf/chef_examples.git'
  cwd repo_directory
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
