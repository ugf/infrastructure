maintainer       'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license          'our license'
description      'Installs basic tools to manage any instance'
long_description ''
version          '0.0.1'

supports 'windows'

depends 'core'
depends 'rightscale'
depends 'windows'

recipe 'gallio::default', 'Downloads and installs gallio'

attribute 'core/aws_access_key_id',
  :display_name => 'aws access key id',
  :required => 'required',
  :recipes => ['gallio::default']

attribute 'core/aws_secret_access_key',
  :display_name => 'aws secret access key',
  :required => 'required',
  :recipes => ['gallio::default']

attribute 'core/repository_source',
  :display_name => 'repository source',
  :description => 'i.e. denver2, s3',
  :choice => ['denver2', 's3'],
  :required => 'optional',
  :default => 's3',
  :recipes => ['gallio::default']

attribute 'core/s3_bucket',
  :display_name => 's3 bucket for the UGF platform',
  :description => 'i.e. ugfartifacts, ugfproduction',
  :required => 'optional',
  :default  => 'ugfgate1',
  :recipes => ['gallio::default']
