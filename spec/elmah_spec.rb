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

    given.template(create_db_script_path).yields
    given.node {{
      elmah: {
        database_user: 'logger',
        database_password: 'logg3r'
      }
    }}

    verify.source "#{create_db_script}.erb"
    verify.variables(
      database_user: 'logger',
      database_password: 'logg3r'
    )

  end

  it 'should generate the db' do

    given.execute(/Create/).yields
    verify.command /sqlcmd.*create/

  end

  it 'should generate setup db script' do

    given.template(setup_db_script_path).yields
    verify.source "#{setup_db_script}.erb"

  end

  it 'should setup the db' do

    given.execute(/Setup/).yields
    verify.command /sqlcmd.*setup/

  end

end