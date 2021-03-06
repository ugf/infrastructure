class Chef::Resource
  include LocalGems
end

class Chef::Recipe
  include DetectVagrant
  include LocalGems
end

emit_marker :begin

gems = {
  'bundle' => '0.0.1',
  'amazon-ec2' => '0.9.17',
  'fog' => '1.1.2',
  'rest-client' => '1.6.7',
  'xml-simple' => '1.1.1',
  'rr' => '1.0.4',
  'rspec' => '2.7.0',
  'simplecov' => '0.6.1',
  'cucumber' => '1.2.1'
}


if node[:platform] == "ubuntu"
  gems['libv8'] = '3.11.8.4'  # libv8 needs a native ruby and is unnecessary on windows
  gems['rails'] = '3.2.11'  # rails needs a native ruby and is unnecessary on windows

  package 'libyaml-dev' do
  end

  execute 'apt-cache policy libyaml-dev' do
    command 'apt-cache policy libyaml-dev'
  end

  gem_package 'psych' do
    version '1.3.2'
    gem_binary('/usr/bin/gem')
    options('--no-rdoc --no-ri')
  end

  execute 'gem update --system' do
    command 'gem update --system'
  end

  package 'libxslt-dev' do
  end

  gem_package 'nokogiri' do
    gem_binary('/usr/bin/gem')
    options('--no-rdoc --no-ri')
  end

  gems_to_install(gems).each do |gem, ver|
    gem_package gem do
      version ver
      gem_binary('/usr/bin/gem')
      options('--no-rdoc --no-ri')
    end
  end
else
  powershell 'Installing ruby gems' do
    script = <<-EOF
& "gem" 'update' '--system'
#{gems_to_install(gems).map { |gem, version| "& 'gem' 'install' '#{gem}' -v '#{version}' '--no-rdoc' '--no-ri' \n" }.join}
    EOF
    source(script)
  end
end

emit_marker :end