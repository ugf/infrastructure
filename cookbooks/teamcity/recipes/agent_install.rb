rightscale_marker :begin

Dir.mkdir('/installs') unless File.exist?('/installs')

template "#{node[:ruby_scripts_dir]}/download_teamcity_agent.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'teamcity',
    :version => '7.1',
    :artifacts => 'TeamCityBuildAgent',
    :target_directory => '/installs'
  )
end

powershell 'Downloading teamcity agent' do
  source("ruby #{node[:ruby_scripts_dir]}/download_teamcity_agent.rb")
  not_if { File.exist?('/installs/TeamCityBuildAgent.zip') }
end

windows_zipfile '/BuildAgent' do
  source '/installs/TeamCityBuildAgent.zip'
  action :unzip
  not_if { File.exist?('/BuildAgent') }
end

template '/installs/buildAgent.properties' do
  source 'buildAgent.properties.erb'
  variables(:web_server => node[:teamcity][:web_server])
end

powershell 'Installing teamcity agent' do
  parameters({ 'PASSWORD' => node[:windows][:administrator_password] })
  script = <<-EOF
    copy-item c:\\installs\\buildAgent.properties c:\\BuildAgent\\conf\\buildAgent.properties

    cd c:\\BuildAgent\\bin

    cmd /c service.install.bat
    cmd /c "sc config TCBuildAgent obj= .\\Administrator password= $env:PASSWORD TYPE= own"
    cmd /c service.start.bat
  EOF
  source(script)
  not_if { File.exist?('c:\BuildAgent\conf\buildAgent.properties') }
end

rightscale_marker :end
