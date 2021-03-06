maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Configures TeamCity'
long_description ''
version '0.0.1'

depends 'rightscale'
depends 'windows'

recipe 'teamcity::web_backup_volumes', 'Backups up TeamCity web server'
recipe 'teamcity::web_configure', 'Configures the web server to use a database server'
recipe 'teamcity::web_delete_volumes', 'Deletes TeamCity web server volumes'
recipe 'teamcity::web_disable_backups', 'Disables backups for the TeamCity web server'
recipe 'teamcity::web_download', 'Downloads the web server install'
recipe 'teamcity::web_enable_backups', 'Enables backups for the TeamCity web server'
recipe 'teamcity::web_schedule_backups', 'Schedules backups for the TeamCity web server'
recipe 'teamcity::web_setup_volumes', 'Sets up TeamCity web server volumes'

recipe 'teamcity::db_configure', 'Configures the database'

recipe 'teamcity::agent_install', 'Installs the agent'

attribute 'core/aws_access_key_id',
  :display_name => 'aws access key id',
  :required => 'required',
  :recipes => [
    'teamcity::agent_install',
    'teamcity::web_delete_volumes',
    'teamcity::web_download',
    'teamcity::web_setup_volumes'
  ]

attribute 'core/aws_secret_access_key',
  :display_name => 'aws secret access key',
  :required => 'required',
  :recipes => [
    'teamcity::agent_install',
    'teamcity::web_delete_volumes',
    'teamcity::web_download',
    'teamcity::web_setup_volumes'
  ]

attribute 'core/s3_bucket',
  :display_name => 's3 bucket for the UGF platform',
  :description => 'i.e. ugfartifacts, ugfproduction',
  :required => 'optional',
  :default => 'ugfgate1',
  :recipes => ['teamcity::agent_install', 'teamcity::web_download']

attribute 'windows/administrator_password',
  :display_name => 'administrator password',
  :required => 'required',
  :recipes => ['teamcity::web_schedule_backups', 'teamcity::agent_install']

attribute 'teamcity/agent_type',
  :display_name => 'agent type',
  :choice => ['unit', 'integration'],
  :required => 'optional',
  :default => 'unit',
  :recipes => ['teamcity::agent_install']

attribute 'teamcity/console_password',
  :display_name => 'console password',
  :required => 'required',
  :recipes => ['teamcity::db_configure']

attribute 'teamcity/console_user',
  :display_name => 'console user',
  :required => 'required',
  :recipes => ['teamcity::db_configure']

attribute 'teamcity/database_server',
  :display_name => 'database server',
  :required => 'required',
  :recipes => ['teamcity::web_configure']

attribute 'teamcity/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['teamcity::web_configure', 'teamcity::db_configure']

attribute 'teamcity/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['teamcity::web_configure', 'teamcity::db_configure']

attribute 'teamcity/data_volume_size',
  :display_name => 'data volume size',
  :required => 'optional',
  :default => '300',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'teamcity/force_create_volumes',
  :display_name => 'force create volumes',
  :required => 'optional',
  :default => 'False',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'teamcity/lineage_name',
  :display_name => 'lineage name',
  :required => 'optional',
  :default => 'TeamCity Web',
  :recipes => ['teamcity::web_backup_volumes', 'teamcity::web_setup_volumes']

attribute 'teamcity/web_server',
  :display_name => 'web server',
  :required => 'required',
  :recipes => ['teamcity::agent_install', 'teamcity::web_configure']