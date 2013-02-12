maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Configures TeamCity'
long_description ''
version '0.0.1'

depends 'rightscale'
depends 'windows'

recipe 'elmah::default', 'Sets up elmah database'

attribute 'teamcity/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['elmah::default']

attribute 'teamcity/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['elmah::default']