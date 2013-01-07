maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

depends 'core'
depends 'rightscale'

recipe "newgen::default", "Deploys New Gen websites"
recipe "newgen::download", "Downloads binaries"

# Attributes from core cookbook
attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["newgen::download"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["newgen::download"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes  => ["newgen::download"]

attribute "core/s3_repository",
  :display_name => "s3 repository for the services api",
  :required => "optional",
  :default  => "NewGen",
  :recipes  => ["newgen::download"]

# Attributes from newgen cookbook
attribute "newgen/binaries_artifacts",
  :display_name => "binaries artifacts",
  :required => "required",
  :recipes => ["newgen::download"]

attribute "newgen/binaries_revision",
  :display_name => "binaries revision",
  :required => "required",
  :recipes => ["newgen::download"]

attribute "newgen/database_server",
  :display_name => "database server ip",
  :required => "required",
  :recipes => ["newgen::default"]



