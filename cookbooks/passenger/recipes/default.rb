
class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

gem_package 'passenger' do
  gem_binary('/usr/bin/gem')
  options('--no-rdoc --no-ri')
end

passenger_packages = ['apache2-prefork-dev', 'libapr1-dev', 'libapache2-mod-passenger']

passenger_packages.each do |name|
  package name do
  end
end

emit_marker :end