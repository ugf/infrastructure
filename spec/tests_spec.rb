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

  end

  describe 'logging server' do

    it 'should run the tests' do

      given.node {{ elmah: {}}}
      given.execute(/Run/).yields

      verify.command /cucumber.*--tags @logging_server/

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

      given.node {{}}
      given.execute(/Run/).yields

      p method :verify

      verify.command /cucumber.*--tags @application_server/

      run_recipe 'tests', 'application_server'

    end

  end

end