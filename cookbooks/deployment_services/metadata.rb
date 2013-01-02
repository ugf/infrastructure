maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"
#depends "logging"

recipe "deployment_services::default", "Deploys Infrastructure api services"

