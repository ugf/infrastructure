
features_directory = node[:features_directory]

Dir.mkdir(features_directory) unless File.exist?(features_directory)

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
