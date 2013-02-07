require 'spec_helper'

describe 'Elastic search' do
  let(:ruby_scripts_dir) { '/rubyscripts' }

  before :each do
    stub_all
    stub_the.node {{
      platform: 'windows',
      ruby_scripts_dir: ruby_scripts_dir,
      windows: { administrator_password: 'pass' }
    }}
  end

  it 'includes download_vendor_artifacts_prereqs recipe' do

    mock_the.include_recipe 'core::download_vendor_artifacts_prereqs'
    run_recipe 'elastic_search'
  end

  it 'is not implemented in ubuntu' do

    stub_the.node {{ platform: 'ubuntu' }}

    expect { run_recipe 'elastic_search' }.
        to raise_error 'Not implemented yet'
  end

  it 'should create the download script' do
    mock_the.template "#{ruby_scripts_dir}/download_elastic_search.rb"

    run_recipe 'elastic_search'
  end

  it 'should be downloaded' do

    mock_the.execute('Download elastic_search').yields
    mock_the.command 'ruby c:\rubyscripts\download_elastic_search.rb'
    stub_the.not_if

    run_recipe 'elastic_search'
  end

  it 'should be unzipped' do

    mock_the.windows_zipfile('/elastic_search').yields
    mock_the.source '/installs/elastic_search.zip'
    stub_the.action
    stub_the.not_if

    run_recipe 'elastic_search'
  end

  it 'should install plugin head' do

    mock_the.execute('Installing plugin elasticsearch-head').yields
    mock_the.command 'plugin.bat -install Aconex/elasticsearch-head'
    mock_the.cwd '/elastic_search/bin'

    run_recipe 'elastic_search'
  end

  it 'should install plugin bigdesk' do

    mock_the.execute('Installing plugin bigdesk').yields
    mock_the.command 'plugin.bat -install lukas-vlcek/bigdesk'
    mock_the.cwd '/elastic_search/bin'

    run_recipe 'elastic_search'
  end

  it 'should schedule a task' do

    mock_the.windows_task('Start Elastic Search').yields
    stub_the.user
    stub_the.password
    mock_the.command 'c:\elastic_search\bin\elasticsearch.bat'
    stub_the.run_level
    stub_the.frequency
    mock_the.action :create

    run_recipe 'elastic_search'
  end

  it 'should start the task' do
    stub_the.windows_task('Start Elastic Search').once
    mock_the.windows_task('Start Elastic Search').yields
    mock_the.action :run

    run_recipe 'elastic_search'
  end

end
