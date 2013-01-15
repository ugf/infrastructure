maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Setup route 53'
long_description ''
version '0.0.1'

supports 'windows'

depends 'rightscale'

recipe 'route53::register', 'register ip with route 53'
recipe 'route53::deregister', 'deregister ip with route 53'

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["route53::register", "route53::deregister"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["route53::register", "route53::deregister"]

attribute "route53/domain",
  :display_name => "route 53 domain",
  :required => "optional",
  :recipes => ["route53::register", "route53::deregister"]

attribute "route53/prefix",
  :display_name => "route 53 prefix",
  :required => "optional",
  :recipes => ["route53::register", "route53::deregister"]

attribute "route53/ip",
  :display_name => "route 53 ip",
  :required => "optional",
  :recipes => ["route53::register", "route53::deregister"]



