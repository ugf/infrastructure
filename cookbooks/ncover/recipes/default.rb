rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'ncover'
download_directory = '/download_ncover'

template "#{node[:ruby_scripts_dir]}/download_ncover.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'ncover',
    :version => '3.4.16.6924',
    :artifacts => artifact,
    :target_directory => download_directory
  )
end

powershell 'Downloading ncover' do
  source("ruby #{node[:ruby_scripts_dir]}/download_ncover.rb")
  not_if { File.exist?("#{download_directory}/#{artifact}.zip") }
end

windows_zipfile "#{download_directory}/#{artifact}" do
  source "#{download_directory}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{download_directory}/#{artifact}") }
end

execute 'Installing ncover' do
  command <<-EOF
    msiexec /i ncover.msi /qn
    \"#{ENV['PROGRAMFILES']}\\NCover\\ncover.registration\" //license license.lic
  EOF
  cwd "#{download_directory}/#{artifact}"
  not_if { File.exist?("#{ENV['PROGRAMFILES']}\\NCover") }
end

rightscale_marker :end