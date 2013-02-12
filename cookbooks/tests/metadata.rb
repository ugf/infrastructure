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
  :recipes => ['tests::default', 'tests::application_server']

attribute 'elmah/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['tests::logging_server']

attribute 'elmah/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['tests::logging_server']

