maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"
depends "logging"

recipe "deployment_services::default", "Deploys Infrastructure api services"
recipe "deployment_services::download", "Downloads infrastructure api"

# Attributes from core cookbook
attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deployment_services::download"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deployment_services::download"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes  => ["deployment_services::download"]

# Attributes from deployment_services cookbook
attribute "deployment_services/infrastructure_artifacts",
  :display_name => "infrastructure artifacts",
  :required => "required",
  :recipes => ["deployment_services::download"]

attribute "deployment_services/infrastructure_revision",
  :display_name => "infrastructure revision",
  :required => "required",
  :recipes => ["deployment_services::download"]

attribute "deployment_services/s3_api_repository",
  :display_name => "s3 repository for the services api",
  :required => "optional",
  :default  => "Infrastructure",
  :recipes  => ["deployment_services::download"]

