rightscale_marker :begin

Dir.mkdir('/installs') unless File.exist?('/installs')

template "#{node[:ruby_scripts_dir]}/download_teamcity_webserver.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'teamcity',
    :version => '7.1',
    :artifacts => 'TeamCity-7.1.2',
    :target_directory => '/installs'
  )
end

powershell 'Downloading teamcity agent' do
  source("ruby #{node[:ruby_scripts_dir]}/download_teamcity_webserver.rb")
  not_if { File.exist?('/installs/TeamCity-7.1.2.zip') }
end

windows_zipfile '/installs' do
  source '/installs/TeamCity-7.1.2.zip'
  action :unzip
  not_if { File.exist?('/installs/TeamCity-7.1.2.exe') }
end

rightscale_marker :end
