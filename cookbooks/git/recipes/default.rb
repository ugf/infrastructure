rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'git_install'
download_directory = '/download_git'

template "#{node[:ruby_scripts_dir]}/download_git.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'git',
    :version => '1.8.0',
    :artifacts => artifact,
    :target_directory => download_directory
  )
end

powershell 'Downloading git' do
  source("ruby #{node[:ruby_scripts_dir]}/download_git.rb")
  not_if { File.exist?("#{download_directory}/#{artifact}.zip") }
end

windows_zipfile "#{download_directory}/#{artifact}" do
  source "#{download_directory}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{download_directory}/#{artifact}") }
end

#execute 'Installing git' do
#  command "#{artifact}.exe /silent"
#  cwd "#{download_directory}/#{artifact}"
#end

rightscale_marker :end