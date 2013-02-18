require 'spec_helper'

describe 'setting up a teamcity db server' do

  it 'should create the database' do
    stub_all

    given.node {
      {
          teamcity: {
              database_user: 'user',
              database_password: 'password'
          }
      }
    }
    given.template('d:\create_database.sql').yields

    verify.source('create_database.erb')
    verify.variables( database_user: 'user', database_password: 'password' )

    run_recipe('teamcity', 'db_configure')
  end
end