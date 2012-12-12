maintainer       'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license          'our license'
description      'Installs visual studio'
long_description ''
version          '0.0.1'

supports 'windows'

depends 'rightscale'
depends 'core'

recipe 'visual_studio::default', 'Downloads and installs visual studio'
recipe 'visual_studio::mstest', 'Downloads and installs visual studio test framework'

attribute 'core/aws_access_key_id',
  :display_name => 'aws access key id',
  :required => 'required',
  :recipes => ['visual_studio::default', 'visual_studio::mstest']

attribute 'core/aws_secret_access_key',
  :display_name => 'aws secret access key',
  :required => 'required',
  :recipes => ['visual_studio::default', 'visual_studio::mstest']