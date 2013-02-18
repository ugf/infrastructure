require 'spec_helper'

describe 'Tests' do

  let(:git) { "\"#{ENV['PROGRAMFILES(X86)']}\\Git\\bin\\git\"" }
  let(:tests_directory) { '/infrastructure_tests' }

  before :each do
    stub_all
  end

  describe 'default' do

    after :each do
      run_recipe 'tests'
    end

    it 'should remove previous dir' do

      given.execute(/Removing/).yields
      verify.command /rd .* \"#{tests_directory}\"/

    end

    it 'should download the tests' do

      given.execute(/Downloading/).yields
      verify.command /git.*clone.*tests/

    end

    it 'should pick the tests revision' do

      given.node {{tests: { revision: 42 }}}
      given.execute(/revision/).yields
      verify.command /git.*checkout 42/

    end

    it 'should create an output folder' do

      given.execute(/Create output/).yields
      verify.command /mkdir/

    end

  end

  describe 'logging server' do

    it 'should run the tests' do

      given.node {{ elmah: {}}}
      given.execute(/Run/).yields

      verify.command /cucumber.*@logging_server.*temp/

      run_recipe 'tests', 'logging_server'

    end

    it 'should set db credentials for tests' do

      given.node {{
        elmah: {
          database_user: 'logger',
          database_password: 'logg3r',
        }
      }}

      run_recipe 'tests', 'logging_server'

      ENV['elmah/database_user'].should == 'logger'
      ENV['elmah/database_password'].should == 'logg3r'

    end

  end

  describe 'application server' do

    it 'should run the tests' do

      given.node {{
        route53: {
          ip: 'ip',
          prefix: 'prefix',
          domain: 'domain'
        }
      }}
      given.execute(/Run/).yields

      p method :verify

      verify.command /cucumber.*application_server.*temp/

      run_recipe 'tests', 'application_server'

      ENV['route53/ip'].should == 'ip'
      ENV['route53/prefix'].should == 'prefix'
      ENV['route53/domain'].should == 'domain'
    end

  end

end