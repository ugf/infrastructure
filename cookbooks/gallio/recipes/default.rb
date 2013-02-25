rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

raise 'Not implemented yet' if node[:platform] == 'ubuntu'

artifact = 'gallio'

template "#{node[:ruby_scripts_dir]}/download_gallio.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :repository_source => node[:core][:repository_source],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => artifact,
    :version => '3.3.458.0',
    :artifacts => artifact,
    :target_directory => node[:installs_directory]
  )
end

execute 'Download gallio' do
  command "ruby #{node[:ruby_scripts_dir]}/download_gallio.rb"
  not_if { File.exist?("#{node[:installs_directory]}/#{artifact}.zip") }
end

windows_zipfile "#{node[:installs_directory]}/#{artifact}" do
  source "#{node[:installs_directory]}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{node[:installs_directory]}/#{artifact}") }
end

windows_package 'Install gallio' do
  source "#{node[:installs_directory]}\\#{artifact}\\GallioBundle-3.4.14.0-Setup-x64.msi"
end

rightscale_marker :end
