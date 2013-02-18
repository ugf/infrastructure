require 'spec_helper'

describe 'setting up a teamcity db server' do
  before { stub_all }
  after { run_recipe('teamcity', 'db_configure') }

  it 'should create the database template' do
    given.node {
      {
          teamcity: {
              database_user: 'user',
              database_password: 'password'
          }
      }
    }

    verify.template('d:\create_database.sql').yields
    verify.source('create_database.erb')
    verify.variables( database_user: 'user', database_password: 'password' )
  end

  it 'should create the database' do
    verify.windows_batch('Create TeamCity database').yields
    verify.code 'sqlcmd -E -id:\create_database.sql'
  end

  it 'should create the console login template' do
    given.node {
      {
        teamcity: {
          console_user: 'user',
          console_password: 'password'
        }
      }
    }

    verify.template('d:\create_console_login.sql').yields
    verify.source('create_console_login.sql.erb')
    verify.variables( console_user: 'user', console_password: 'password' )
  end

  it 'should create the console login' do
    verify.windows_batch('Create console login').yields
    verify.code 'sqlcmd -E -id:\create_console_login.sql'
  end
end