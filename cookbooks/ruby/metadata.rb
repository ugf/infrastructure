maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"
supports "windows"

depends 'core'
depends "rightscale"
depends "windows"

recipe "ruby::default", "Runs all ruby recipes"
recipe "ruby::devkit", "Downloads and installs devkit"
recipe "ruby::install", "Downloads and installs ruby"
recipe "ruby::gems", "Installs ruby gems"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["ruby::install", "ruby::devkit"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["ruby::install", "ruby::devkit"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["ruby::install", "ruby::devkit"]
