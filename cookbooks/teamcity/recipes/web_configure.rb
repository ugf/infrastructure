rightscale_marker :begin

require 'fileutils'

teamcity_path = 'd:\TeamCity'
webapps = 'C:\TeamCity\webapps\ROOT\WEB-INF\lib'

cookbook_file "#{webapps}\\antlr-2.7.7.jar" do
  source 'antlr-2.7.7.jar'
end

cookbook_file "#{webapps}\\asm-2.2.3.jar" do
  source 'asm-2.2.3.jar'
end

cookbook_file "#{webapps}\\groovy-1.6.4.jar" do
  source 'groovy-1.6.4.jar'
end

cookbook_file "#{teamcity_path}\\plugins\\groovyPlug.zip" do
  source 'groovyPlug.zip'
end

cookbook_file "#{teamcity_path}\\lib\\jdbc\\jtds-1.2.5.jar" do
  source 'jtds-1.2.5.jar'
end

template "#{teamcity_path}\\config\\database.properties" do
  source 'database.properties.erb'
  variables(
    :database_server => node[:teamcity][:database_server],
    :database_user => node[:teamcity][:database_user],
    :database_password => node[:teamcity][:database_password]
  )
end

template "#{teamcity_path}\\config\\license.keys" do
  source 'license.keys.erb'
end

template "#{teamcity_path}\\config\\_notifications\\jabber\\jabber-config.xml" do
  source 'jabber-config.xml.erb'
end

template "#{node[:ruby_scripts_dir]}/setup_ldap.rb" do
  source 'scripts/setup_ldap.erb'
  variables(:config_file => "#{teamcity_path}\\config\\main-config.xml")
end

powershell('Setup ldap') do
  source("ruby #{node[:ruby_scripts_dir]}/setup_ldap.rb")
  not_if { File.read("#{teamcity_path}\\config\\main-config.xml").include?('login-module') }
end

template "#{node[:ruby_scripts_dir]}/setup_server_url.rb" do
  source 'scripts/setup_server_url.erb'
  variables(:config_file => "#{teamcity_path}\\config\\main-config.xml", :web_server => node[:teamcity][:web_server])
end

powershell('Setup server url') do
  source("ruby #{node[:ruby_scripts_dir]}/setup_server_url.rb")
end

template "#{teamcity_path}\\config\\ldap-config.properties" do
  source 'ldap-config.properties.erb'
end

env('TEAMCITY_SERVER_MEM_OPTS') { value '-Xmx1300m -XX:MaxPermSize=270m' }

powershell('Configure TeamCity service') do
  script = <<'EOF'
    $service = 'TeamCity'

    Set-Service -name $service -startupType manual
    sc.exe failure $service reset= 86400 actions= restart/5000
EOF
  source(script)
end

powershell('Restart TeamCity') do
  source('Restart-Service TeamCity')
end

rightscale_marker :end