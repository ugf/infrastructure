
purge_packages = ['apparmor', 'apt-xapian-index', 'aptitude', 'augeas-lenses', 'debconf-utils', 'installation-report',
  'language-pack-en-base', 'libexpat1', 'linux-generic-pae', 'linux-headers-generic',
  'linux-image-generic-pae', 'module-assistant', 'ruby-dev'
]

purge_packages.each do |name|
  package name do
    action :purge
  end
end

#todo: need rightscale install
#todo: 'libarchive-dev', 'libarchive12', 'libltdl-dev', 'libncurses5-dev', 'libnettle4',  'libreadline-gplv2-dev', 'libtinfo-dev', 'libtool',  'libxml2-dev', 'libxslt1-dev', 'libxslt1.1',
install_packages = [ 'accountsservice', 'acpid', 'autoconf', 'bison', 'command-not-found', 'curl', 'dhcp3-client', 'emacs', 'emacs23', 'flex', 'git',
  'git-core', 'grub-legacy-ec2', 'iptraf', 'iw', 'mailutils', 'nscd', 'rake',
  'screen', 'sqlite3', 'subversion', 'sysstat', 'tmux', 'ubuntu-minimal', 'ubuntu-standard', 'ufw', 'vim', 'zlib1g-dev'
]

bash 'Upgrading repositories' do
  code 'apt-get update'
end

install_packages.each do |name|
  package name do
  end
end

bash 'Autoremove temp packages' do
  code 'apt-get -y autoremove'
end