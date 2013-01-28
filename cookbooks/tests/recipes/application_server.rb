
log "Cache path: #{p Chef::Config}"

features_directory = node[:features_directory]

Dir.mkdir(features_directory) unless File.exist?(features_directory)

template "#{features_directory}/mstest.feature" do
  source 'features/mstest.feature.erb'
end

Dir.mkdir("#{features_directory}/step_definitions") unless File.exist?("#{features_directory}/step_definitions")

template "#{features_directory}/step_definitions/file_system.rb" do
  source 'features/step_definitions/file_system.rb.erb'
end

template "#{features_directory}/run_feature_for.rb" do
  source 'scripts/run_feature_for.rb.erb'
  variables(:tags => '@application_server')
end

powershell('Running tests') do
  source("ruby #{features_directory}/run_feature_for.rb")
end