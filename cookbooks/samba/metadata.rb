maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Samba pa ti"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends 'rightscale'

recipe "samba::default", "install samba"
