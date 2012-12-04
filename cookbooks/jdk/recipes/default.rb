rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifact = 'jdk_windows'
download_directory = '/download_jdk'
install_directory = '/jdk'

template "#{node[:ruby_scripts_dir]}/download_jdk.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'jdk',
    :version => '1.7.0',
    :artifacts => artifact,
    :target_directory => download_directory
  )
  not_if { File.exist?(install_directory) }
end

powershell 'Downloading jdk' do
  source("ruby #{node[:ruby_scripts_dir]}/download_jdk.rb")
  not_if { File.exist?("#{download_directory}/#{artifact}.zip") }
end

windows_zipfile "#{download_directory}/#{artifact}" do
  source "#{download_directory}/#{artifact}.zip"
  action :unzip
  not_if { File.exist?("#{download_directory}/#{artifact}") }
end

powershell 'Installing jdk' do
  script = <<-EOF
    cd /download_jdk/jdk_windows
    cmd /c 'msiexec.exe /i jdk1.7.0_07.msi /qn INSTALLDIR=c:\\jdk'
  EOF
  source(script)
  not_if { File.exist?(install_directory) }
end

env('JAVA_HOME') { value 'c:\jdk\bin' }
env('JRE_HOME') { value 'c:\jdk\bin' }

env('PATH') do
  action :modify
  delim ::File::PATH_SEPARATOR
  value 'C:\jdk\bin'
end

rightscale_marker :end