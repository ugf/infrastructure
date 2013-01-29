
include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_devkit.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'devkit',
    :version => '4.5.2',
    :artifacts => 'devkit',
    :target_directory => '/installs'
  )
  not_if { File.exist?('/installs/devkit.zip') }
end

if node[:platform] != "ubuntu"
  powershell 'Download devkit' do
    script = <<'EOF'
    cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"
    cmd /c ruby -rubygems c:\\rubyscripts\\download_devkit.rb
EOF
    source(script)
    not_if { File.exist?('/devkit') }
  end
end

windows_zipfile '/installs/devkit' do
  source '/installs/devkit.zip'
  action :unzip
  not_if { File.exist?('/installs/devkit') }
end

windows_zipfile '/devkit' do
  source '/installs/devkit/devkit.exe'
  action :unzip
  not_if { File.exist?('/devkit') }
end

execute 'Initializing devkit' do
  command 'ruby dk.rb init'
  cwd '/devkit'
end

execute 'Installing devkit' do
  command 'ruby dk.rb install'
  cwd '/devkit'
end

#powershell 'Install devkit' do
#  source('c:\\installs\\devkit\\devkit.exe /tasks=modpath /silent')
#  not_if { File.exist?('/devkit') }
#end