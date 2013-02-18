require 'spec_helper'

describe 'setting up a teamcity web server' do

  it 'should set the memory options' do
    stub_all

    given.node {
      {
          ruby_scripts_dir: '/ruby_scripts_dir'
      }
    }

    given.env('TEAMCITY_SERVER_MEM_OPTS').yields

    verify.value '-Xmx1300m -XX:MaxPermSize=270m'

    #To change this template use File | Settings | File Templates.
    run_recipe 'teamcity', 'web_configure'
  end
end