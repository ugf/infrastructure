class Chef::Resource
  include DetectVagrant
end

class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

bash 'Set document root and configure Passenger' do
  code <<-EOF
    if grep -q DocumentRoot /etc/apache2/apache2.conf; then
        echo "document root already set"
        exit 0
    fi

    echo LoadModule passenger_module /opt/ruby/1.9.2-p320/lib/ruby/gems/1.9.1/gems/passenger-3.0.18/ext/apache2/mod_passenger.so >> /etc/apache2/apache2.conf
    echo PassengerRoot /opt/ruby/1.9.2-p320/lib/ruby/gems/1.9.1/gems/passenger-3.0.18 >> /etc/apache2/apache2.conf
    echo PassengerRuby /usr/bin/ruby >> /etc/apache2/apache2.conf
    echo PassengerDefaultUser root >> /etc/apache2/apache2.conf

    echo DocumentRoot "/var/www/api/public" >> /etc/apache2/apache2.conf
  EOF
end

template '/etc/apache2/conf.d/status.conf' do
  source 'status_conf.erb'
end

template "/var/www/HealthCheck.html" do
  mode "0644"
  source 'health_check.erb'
end

bash 'Setup website' do
  code <<-EOF
    mkdir --parents /var/www/api
    cp -r #{node[:infrastructure_directory]}/InfrastructureServices/* /var/www/api

    echo "" >> /var/www/api/log/production.log
    echo "" >> /var/log/rest.log
    chmod --recursive 0666 /var/www/api/log
    chown --recursive www-data:www-data /var/www/api/log

    cp /var/www/HealthCheck.html /var/www/api/doc

    cd /var/www/api

    bundle install

    service apache2 restart

    curl http://localhost/deployments.json
  EOF
end

ruby_block 'Processing rest.log via logs' do
  block do
    config_file = '/etc/rsyslog.conf'
    target = <<-'eof'
ModLoad imklog
$ModLoad imfile

$InputFileName /var/log/rest.log
$InputFileTag rest:
$InputFileStateFile stat-rest-log
$InputFileSeverity error
$InputFileFacility local7
$InputRunFileMonitor

$InputFilePollingInterval 10

    eof

    text = File.read(config_file)
    modified = text.gsub(/#{'ModLoad imklog'}/, target)
    File.open(config_file, 'w') { |f| f.puts(modified) }
  end
  not_if { File.read('/etc/rsyslog.conf').include?('rest.log') }
end

logging('default') do
  action :restart
  not_if { vagrant_exists? }
end

emit_marker :end