maintainer       'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license          'our license'
description      'Deploys the UGF software to the environment'
long_description ''
version          '0.0.1'

supports 'windows'

depends 'rightscale'
depends 'windows'

recipe 'iis::default', 'enables iis'
recipe 'iis::create_deploy_website', 'generates a template for deploying websites in iis'

attribute 'windows/administrator_password',
  :display_name => 'administrator password',
  :required => 'required',
  :recipes => ['iis::create_deploy_website']
