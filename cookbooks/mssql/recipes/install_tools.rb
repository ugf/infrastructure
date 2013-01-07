rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'sql_tools'
installs_directory = '/installs'

template "#{node[:ruby_scripts_dir]}/download_sql_tools.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'sql_tools',
    :version => 'sql_2008',
    :artifacts => artifact,
    :target_directory => installs_directory
  )
end

powershell 'Downloading sql tools' do
  source("ruby #{node[:ruby_scripts_dir]}/download_sql_tools.rb")
  not_if { File.exist?("#{installs_directory}/#{artifact}.zip") }
end

windows_zipfile "#{installs_directory}/#{artifact}" do
  source "#{installs_directory}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{installs_directory}/#{artifact}") }
end

windows_package 'Installing sql native client' do
  source "#{installs_directory}/sql_tools/sqlncli.msi"
end

windows_package 'Installing sql command line tools' do
  source "#{installs_directory}/sql_tools/SqlCmdLnUtils.msi"
end

#powershell 'Installing sql_tools' do
#  script = <<-EOF
#    cd /installs/sql_tools
#    .\\dotNetFx45_Full_setup.exe /q
#  EOF
#  source(script)
#end

rightscale_marker :end