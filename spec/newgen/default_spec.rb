require 'spec_helper'

require_relative '../../cookbooks/newgen/libraries/config_files'

include ConfigFiles

describe 'newgen' do

  before { stub_all }
  after { run_recipe 'newgen' }

  it 'should include the download recipe' do
    verify.include_recipe 'newgen::download'
  end

  it 'should add the STS certificate' do
    given.execute('Adding certificate').yields
    given.node {
      {
        binaries_directory: 'cert_directory'
      }
    }

    verify.command 'certutil -f -p password -importpfx passiveSTS.pfx'
    verify.cwd 'cert_directory/certificate'
  end
end