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

      stub_the.execute(/Removing/).yields
      mock_the.command /rd .* \"#{tests_directory}\"/

    end

    it 'should download the tests' do

      stub_the.execute(/Downloading/).yields
      mock_the.command /git.*clone.*tests/

    end

    it 'should pick the tests revision' do

      stub_the.node {{tests: { revision: 42 }}}
      stub_the.execute(/revision/).yields
      mock_the.command /git.*checkout 42/

    end

  end

  describe 'logging server' do

    before :each do
    end

    it 'should run the tests' do

      stub_the.node {{ elmah: {}}}
      stub_the.execute(/Run/).yields

      mock_the.command /cucumber.*--tags @logging_server/

      run_recipe 'tests', 'logging_server'

    end

    it 'should set db credentials for tests' do

      stub_the.node {{
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

end