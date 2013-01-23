maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Deploys the UGF software to the environment'
long_description ''
version '0.0.1'

supports 'ubuntu'

depends 'route53'
depends 'rightscale'

recipe 'load_balancer::configure', 'Adds an entry vhost (frontend) that forwards requests to the next target'
recipe 'load_balancer::connect', 'Registers with each load balancer'
recipe 'load_balancer::connect_instance', 'Registers an instance with haproxy'
recipe 'load_balancer::disconnect', 'Disconnects from load balancers'
recipe 'load_balancer::disconnect_instance', 'Disconnects an instance from the haproxy'

attribute 'load_balancer/backend_name',
  :display_name => 'backend name',
  :description => 'A unique name for each back end e.g. (RS_INSTANCE_UUID)',
  :required => 'optional',
  :recipes => ['load_balancer::connect', 'load_balancer::disconnect']

attribute 'load_balancer/forwarding_ports',
  :display_name => 'forwarding ports',
  :description => 'The list of ports to be forwarded by the load balancer (i.e. 80,81,82,443)',
  :required => 'required',
  :recipes => [
    'load_balancer::configure',
    'load_balancer::connect_instance',
    'load_balancer::disconnect_instance'
  ]

attribute 'load_balancer/instance_backend_name',
  :display_name => 'instance backend name',
  :description => 'instance backend name to be disconnected from haproxy',
  :required => 'required',
  :recipes => [
    'load_balancer::disconnect_instance',
    'load_balancer::connect_instance',
  ]

attribute 'load_balancer/instance_ip',
  :display_name => 'instance ip',
  :description => 'instance ip to be registered with haproxy',
  :required => 'required',
  :recipes => ['load_balancer::connect_instance']

attribute 'load_balancer/prefix',
  :display_name => 'prefix',
  :description => 'The prefix for the load balancer listener (ie, www or api)',
  :choice => ['api', 'www'],
  :required => 'optional',
  :default => 'www',
  :recipes => [
    'load_balancer::configure',
    'load_balancer::connect',
    'load_balancer::connect_instance',
    'load_balancer::disconnect',
    'load_balancer::disconnect_instance'
  ]

attribute 'load_balancer/server_ip',
  :display_name => 'server ip',
  :required => 'required',
  :recipes => ['load_balancer::connect']

attribute 'load_balancer/should_register_with_lb',
  :display_name => 'should register with load balancer',
  :description => 'This environment uses load balancers (true/false)',
  :required => 'optional',
  :default => 'false',
  :recipes => ['load_balancer::connect', 'load_balancer::disconnect']

attribute 'load_balancer/ssl_certificate',
  :display_name => 'ssl certificate',
  :description => "The contents of the SSL Certificate which can be obtained from the 'mycert.crt' file.",
  :required => 'required',
  :recipes => ['load_balancer::configure']

attribute 'load_balancer/ssl_key',
  :display_name => 'ssl key',
  :description => "The contents of the SSL key file (key.pem) that's required for secure (https) connections.",
  :required => 'required',
  :recipes => ['load_balancer::configure']