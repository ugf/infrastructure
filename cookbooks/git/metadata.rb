maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Installs git"
long_description ""
version          "0.0.1"

supports "windows"

depends 'core'
depends 'rightscale'
depends 'windows'

recipe "git::default", "Downloads and installs git"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["git::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["git::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["git::default"]
