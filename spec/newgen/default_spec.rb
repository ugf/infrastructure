require 'spec_helper'

require_relative '../../cookbooks/newgen/libraries/config_files'

include ConfigFiles

describe 'newgen' do

  it 'should add the STS certificate' do
    stub_all

    given.execute('Adding certificate').yields
    given.node {
      {
          binaries_directory: 'cert_directory'
      }
    }

    verify.command 'certutil -f -p password -importpfx passiveSTS.pfx'
    verify.cwd 'cert_directory/certificate'

    run_recipe 'newgen'
  end
end