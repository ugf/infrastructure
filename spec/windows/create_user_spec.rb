require 'spec_helper'

describe 'Create user' do

  before { stub_all }
  after { run_recipe 'windows', 'create_user' }

  it 'should create it' do

    given.node {{
      windows: {
        new_user_name: 'john',
        new_user_password: 'j0hn'
      }
    }}
    given.execute.yields
    verify.command /net user john j0hn/

  end

end