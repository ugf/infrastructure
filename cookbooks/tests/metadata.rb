maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Runs smoke tests'
long_description ''
version '0.0.1'

depends 'rightscale'

recipe 'tests::default', 'Downloads tests'
recipe 'tests::application_server', 'Verifies the application server is functional'
recipe 'tests::logging_server', 'Verifies the logging server is functional'

attribute 'tests/revision',
  :display_name => 'tests revision',
  :required => 'required',
  :recipes => ['tests::default', 'tests::application_server', 'tests::logging_server']

attribute 'elmah/logging_server',
  :display_name => 'logging server',
  :required => 'required',
  :recipes => ['tests::application_server']

attribute 'elmah/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['tests::application_server', 'tests::logging_server']

attribute 'elmah/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['tests::application_server', 'tests::logging_server']

attribute "newgen/database_password",
  :display_name => "database password",
  :required => "required",
  :recipes => ["tests::application_server"]

attribute "newgen/database_server",
  :display_name => "database server",
  :required => "required",
  :recipes => ["tests::application_server"]

attribute "newgen/database_user",
  :display_name => "database user",
  :required => "required",
  :recipes => ["tests::application_server"]

attribute "route53/domain",
  :display_name => "route 53 domain",
  :required => "optional",
  :recipes => ['tests::application_server']

attribute "route53/prefix",
  :display_name => "route 53 prefix",
  :required => "optional",
  :recipes => ['tests::application_server']

attribute "route53/ip",
  :display_name => "route 53 ip",
  :required => "optional",
  :recipes => ['tests::application_server']

attribute 'windows/new_user_name',
  :display_name => 'new user name',
  :required => 'required',
  :recipes => ['tests::application_server']

