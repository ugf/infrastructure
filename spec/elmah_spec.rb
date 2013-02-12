require 'spec_helper'

describe 'elmah' do

  let(:create_db_script) { 'create_database.sql' }
  let(:create_db_script_path) { "c:\\#{create_db_script}" }
  let(:setup_db_script) { 'setup_database.sql' }
  let(:setup_db_script_path) { "c:\\#{setup_db_script}" }

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

    stub_the.execute('Create elmah database').yields
    mock_the.command "sqlcmd -E -i#{create_db_script_path}"

  end

  it 'should generate setup db script' do

    stub_the.template(setup_db_script_path).yields
    mock_the.source "#{setup_db_script}.erb"

  end

  it 'should setup the db' do

    stub_the.execute('Setup elmah database').yields
    mock_the.command "sqlcmd -E -i#{setup_db_script_path}"

  end

end