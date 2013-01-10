maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

depends 'rightscale'

recipe "windows::assign_logon_as_a_service_to_administrator", "assign logon as a service to administrator"
recipe "windows::set_administrator_password", "sets the administrator password"
recipe "windows::set_rightlink_to_run_as_administrator", "sets the the rightlink service to run as administrator"

attribute "windows/administrator_password",
  :display_name => "administrator password",
  :required => "required",
  :recipes => ["windows::set_administrator_password", "windows::set_rightlink_to_run_as_administrator"]