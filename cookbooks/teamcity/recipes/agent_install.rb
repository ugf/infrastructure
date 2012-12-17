rightscale_marker :begin

Dir.mkdir('/installs') unless File.exist?('/installs')
artifact = 'TeamCityBuildAgent'

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
    :artifacts => artifact,
    :target_directory => '/installs'
  )
end

if node[:platform] == 'ubuntu'
  bash 'Downloading teamcity agent' do
    code "ruby #{node[:ruby_scripts_dir]}/download_teamcity_agent.rb"
    not_if { File.exist?("/installs/#{artifact}.zip") }
  end

  bash 'Installing teamcity agent' do
    code <<-EOF
      unzip -d /opt/buildagent /installs/#{artifact}.zip

      cd /opt/buildagent

      properties_file='conf/buildAgent.properties'

      sudo cp conf/buildAgent.dist.properties $properties_file

      echo "configuring agent properties"
      sed -i "s@http://localhost:8111/@http://#{node[:teamcity][:web_server]}@" $properties_file

      echo -e "\nenv.RubyPath=/usr/local/ruby192/bin/ruby" >> $properties_file
      echo -e "\nenv.JAVA_HOME=/jdk/jdk1.7.0_07" >> $properties_file
      echo -e "\nenv.JRE_HOME=/jdk/jdk1.7.0_07" >> $properties_file
      echo -e "\nagent.type=#{node[:teamcity][:agent_type]}" >> $properties_file

      echo "Setting execution permissions to the bin/agent.sh shell script"
      chmod 751 bin/agent.sh
    EOF
    not_if { File.exist?('/opt/buildagent') }
  end

  template '/etc/init.d/teamcity_agent' do
    source 'teamcity_agent.erb'
    mode '0700'
  end

  bash 'Starting teamcity agent' do
    code <<-EOF
      update-rc.d teamcity_agent defaults
      service teamcity_agent start
    EOF
  end
else
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
    variables(
      :web_server => node[:teamcity][:web_server],
      :agent_type => node[:teamcity][:agent_type]
    )
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
end

rightscale_marker :end
