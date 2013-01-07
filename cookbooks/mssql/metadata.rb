maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

depends "rightscale"
depends "windows"

recipe "mssql::set_sa_password", "sets sa password"
recipe "mssql::install_tools", "installs sql tools"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["mssql::install_tools"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["mssql::install_tools"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["mssql::install_tools"]

attribute "mssql/sa_password",
  :display_name => "sa password",
  :required => "required",
  :recipes => ["mssql::set_sa_password"]