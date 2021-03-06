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
recipe "windows::install_winhttpcertcfg", "installs winhttpcertcfg"
recipe "windows::share_temp_folder", "share the temp folder"
recipe "windows::create_user", "create a new windows user"

attribute "windows/administrator_password",
  :display_name => "administrator password",
  :required => "required",
  :recipes => ["windows::set_administrator_password", "windows::set_rightlink_to_run_as_administrator"]

attribute 'windows/new_user_name',
  :display_name => 'new user name',
  :required => 'required',
  :recipes => ['windows::create_user']

attribute 'windows/new_user_password',
  :display_name => 'new user password',
  :required => 'required',
  :recipes => ['windows::create_user']
