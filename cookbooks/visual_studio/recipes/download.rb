rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_visual_studio.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'visualstudio',
    :version => '2012',
    :artifacts => 'VS_2012_Premium',
    :target_directory => '',
    :unzip => true
  )
end

powershell 'downloading visual studio' do
  source("ruby #{node[:ruby_scripts_dir]}/download_visual_studio.rb")
end

rightscale_marker :end