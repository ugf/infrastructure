require 'spec_helper'

describe 'elmah' do

  let(:create_db_script) { 'create_database.sql' }
  let(:create_db_script_path) { "c:\\#{create_db_script}" }

  before :each do
    stub_all
  end

  after :each do
    run_recipe 'elmah'
  end

  it 'should generate create db script' do

    stub_the.template(create_db_script_path).yields
    stub_the.node {{
      elmah: {
        database_user: 'logger',
        database_password: 'logg3r'
      }
    }}

    mock_the.source "#{create_db_script}.erb"
    mock_the.variables(
      database_user: 'logger',
      database_password: 'logg3r'
    )

  end

  it 'should generate the db' do
  end

end