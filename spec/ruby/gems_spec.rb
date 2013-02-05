require 'spec_helper'

describe 'ruby gems' do
  before :each do
    stub_the.emit_marker
  end

  let(:gems) { {
    'bundle' => '0.0.1',
    'amazon-ec2' => '0.9.17',
    'fog' => '1.1.2',
    'rest-client' => '1.6.7',
    'xml-simple' => '1.1.1',
    'rr' => '1.0.4',
    'rspec' => '2.7.0',
    'simplecov' => '0.6.1',
    'cucumber' => '1.2.1'
  } }

  context 'when platform is ubuntu' do

    before :each do
      gems['libv8'] = '3.11.8.4'
      gems['rails'] = '3.2.11'
      stub_the.package
      stub_the.gem_package
      stub_the.execute
      stub_the.gems_to_install { {} }
      stub_the.node { { platform: 'ubuntu' } }
    end

    it 'should install package libyaml-dev' do
      mock_the.package('libyaml-dev')

      run_recipe 'ruby', 'gems'
    end

    it 'should execute apt-cache policy libyaml-dev' do
      mock_the.execute('apt-cache policy libyaml-dev').yields
      mock_the.command 'apt-cache policy libyaml-dev'

      run_recipe 'ruby', 'gems'
    end

    it 'should install gem package psych' do
      mock_the.gem_package('psych').yields
      mock_the.version '1.3.2'
      mock_the.gem_binary '/usr/bin/gem'
      mock_the.options '--no-rdoc --no-ri'

      run_recipe 'ruby', 'gems'
    end

    it 'should execute gem update' do
      mock_the.execute('gem update --system').yields
      mock_the.command 'gem update --system'

      run_recipe 'ruby', 'gems'
    end

    it 'should install package libxslt-dev' do
      mock_the.package('libxslt-dev')

      run_recipe 'ruby', 'gems'
    end

    it 'should install gem package nokogiri' do
      mock_the.gem_package('nokogiri').yields
      mock_the.gem_binary '/usr/bin/gem'
      mock_the.options '--no-rdoc --no-ri'

      run_recipe 'ruby', 'gems'
    end

    it 'should install all the gems list' do
      mock_the.gems_to_install(gems) { gems }
      gems.each do |gem, ver|
        mock_the.gem_package(gem).yields
        mock_the.version ver
        mock_the.gem_binary '/usr/bin/gem'
        mock_the.options '--no-rdoc --no-ri'
      end

      run_recipe 'ruby', 'gems'
    end
  end

  context 'when platform is windows' do

    before :each do
      stub_the.powershell
      stub_the.node { { platform: 'windows' } }
    end

    it 'should install all ruby gems' do
      mock_the.powershell('Installing ruby gems').yields
      expected_commands = [ '& "gem" \'update\' \'--system\'' ]
      mock_the.gems_to_install(gems) { gems }
      gems.each do |gem, ver|
        expected_commands << "& 'gem' 'install' '#{gem}' -v '#{ver}' '--no-rdoc' '--no-ri'"
      end

      mock_the.source(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby', 'gems'
    end

  end
end