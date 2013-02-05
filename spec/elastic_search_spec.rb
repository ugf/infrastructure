require 'spec_helper'

describe 'Elastic search' do

  before :each do
    stub_the.emit_marker
    stub_the.include_recipe
    stub_the.template
    stub_the.execute
    stub_the.windows_zipfile
    stub_the.windows_task
    stub_the.node {{
      platform: 'windows'
    }}
  end

  it 'includes download_vendor_artifacts_prereqs recipe' do

    mock_the.include_recipe 'core::download_vendor_artifacts_prereqs'
    run_recipe 'elastic_search'
  end

  it 'is not implemented in ubuntu' do

    stub_the.node {{ platform: 'ubuntu' }}

    main.node[:platform] = 'ubuntu'
    expect { run_recipe 'elastic_search' }.
        to raise_error 'Not implemented yet'
  end
end
