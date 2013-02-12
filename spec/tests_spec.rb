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

end