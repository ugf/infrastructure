
packages = ['apparmor', 'apt-xapian-index', 'aptitude', 'augeas-lenses', 'debconf-utils', 'installation-report',
  'language-pack-en-base', 'libbind9-80', 'libexpat1', 'linux-generic-pae', 'linux-headers-generic',
  'linux-image-generic-pae', 'module-assistant', 'ruby-dev'
]

packages.each do |name|
  package name do
    action :purge
  end
end
