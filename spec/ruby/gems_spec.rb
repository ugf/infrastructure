require_relative '../spec_helper'

main = self

module DetectVagrant
end
module LocalGems
end

module Chef
  class Resource
  end
  class Recipe
  end
end

describe 'ruby gems' do
  before :each do
    stub(main).emit_marker
  end

  gems = {
    'bundle' => '0.0.1',
    'amazon-ec2' => '0.9.17',
    'fog' => '1.1.2',
    'rest-client' => '1.6.7',
    'xml-simple' => '1.1.1',
    'rr' => '1.0.4',
    'rspec' => '2.7.0',
    'simplecov' => '0.6.1',
    'cucumber' => '1.2.1',
    'rails' => '3.2.11'
  }

  context 'when platform is ubuntu' do

    before :each do
      gems['libv8'] = '3.11.8.4'
      stub(main).package
      stub(main).gem_package
      stub(main).execute
      stub(main).gems_to_install { {} }
      stub(main).node { { platform: 'ubuntu' } }
    end

    it 'should install package libyaml-dev' do
      mock(main).package('libyaml-dev')

      run_recipe 'ruby', 'gems'
    end

    it 'should execute apt-cache policy libyaml-dev' do
      mock(main).execute('apt-cache policy libyaml-dev').yields
      mock(main).command 'apt-cache policy libyaml-dev'

      run_recipe 'ruby', 'gems'
    end

    it 'should install gem package psych' do
      mock(main).gem_package('psych').yields
      mock(main).version '1.3.2'
      mock(main).gem_binary '/usr/bin/gem'
      mock(main).options '--no-rdoc --no-ri'

      run_recipe 'ruby', 'gems'
    end

    it 'should execute gem update' do
      mock(main).execute('gem update --system').yields
      mock(main).command 'gem update --system'

      run_recipe 'ruby', 'gems'
    end

    it 'should install package libxslt-dev' do
      mock(main).package('libxslt-dev')

      run_recipe 'ruby', 'gems'
    end

    it 'should install gem package nokogiri' do
      mock(main).gem_package('nokogiri').yields
      mock(main).gem_binary '/usr/bin/gem'
      mock(main).options '--no-rdoc --no-ri'

      run_recipe 'ruby', 'gems'
    end

    it 'should install all the gems list' do
      mock(main).gems_to_install(gems) { gems }
      gems.each do |gem, ver|
        mock(main).gem_package(gem).yields
        mock(main).version ver
        mock(main).gem_binary '/usr/bin/gem'
        mock(main).options '--no-rdoc --no-ri'
      end

      run_recipe 'ruby', 'gems'
    end
  end
end