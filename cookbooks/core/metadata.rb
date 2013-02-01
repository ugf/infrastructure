maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"

recipe "core::download_product_artifacts_prereqs", "Sets up prereqs for downloading product artifacts"
recipe "core::download_vendor_artifacts_prereqs", "Sets up prereqs for downloading vendor artifacts"
recipe "core::monkey_patch_powershell", "Makes opscode powershell resource look like rightscale's"
recipe "core::setup_powershell_runtimes", "Allows up the poweshell to run multiple runtimes"
recipe "core::tag_server_hostname", "Tags the server host name"
recipe "core::tag_server_type", "Tags the server type"

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache, messaging, or search",
  :required => "required",
  :recipes => ["core::tag_server_type"]