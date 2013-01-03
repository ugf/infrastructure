rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'dot_net'
download_directory = '/download_dot_net'

template "#{node[:ruby_scripts_dir]}/download_dot_net.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'dot_net',
    :version => '4.5',
    :artifacts => artifact,
    :target_directory => download_directory
  )
end

powershell 'Downloading dot_net' do
  source("ruby #{node[:ruby_scripts_dir]}/download_dot_net.rb")
  not_if { File.exist?("#{download_directory}/#{artifact}.zip") }
end

windows_zipfile "#{download_directory}/#{artifact}" do
  source "#{download_directory}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{download_directory}/#{artifact}") }
end

powershell 'Installing dot_net' do
  script = <<-EOF
    cd /download_dot_net/dot_net
    .\\dotNetFx45_Full_setup.exe /q
  EOF
  source(script)
end

rightscale_marker :end