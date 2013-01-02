
class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

gem_package 'passenger' do
  gem_binary('/usr/bin/gem')
  options('--no-rdoc --no-ri')
end

passenger_packages = ['apache2-prefork-dev', 'libapr1-dev', 'libcurl4-openssl-dev']

passenger_packages.each do |name|
  package name do
  end
end

execute 'compile passenger' do
  command './passenger-install-apache2-module --auto'
  cwd '/opt/ruby/1.9.2-p320/lib/ruby/gems/1.9.1/gems/passenger-3.0.18/bin'
end

emit_marker :end