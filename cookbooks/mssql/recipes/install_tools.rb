rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'sql_tools'
template "#{node[:ruby_scripts_dir]}/download_sql_tools.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'sql_tools',
    :version => 'sql2008',
    :artifacts => artifact,
    :target_directory => node[:installs_directory]
  )
end

powershell 'Downloading sql tools' do
  source("ruby #{node[:ruby_scripts_dir]}/download_sql_tools.rb")
  not_if { File.exist?("#{node[:installs_directory]}/#{artifact}.zip") }
end

windows_zipfile "#{node[:installs_directory]}/#{artifact}" do
  source "#{node[:installs_directory]}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{node[:installs_directory]}/#{artifact}") }
end

windows_package 'Installing sql native client' do
  source "#{node[:installs_directory]}\\sql_tools\\sqlncli.msi"
end

windows_package 'Installing sql command line tools' do
  source "#{node[:installs_directory]}\\sql_tools\\SqlCmdLnUtils.msi"
end

rightscale_marker :end