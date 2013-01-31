require_relative '../spec_helper'

describe 'rsyslog' do
  let(:ruby_scripts_dir) { '/rubyscripts' }

  before :each do
    stub_the.rightscale_marker
    stub_the.include_recipe
    stub_the.template
    stub_the.powershell
    stub_the.windows_zipfile
    stub_the.node { { ruby_scripts_dir: '/rubyscripts' } }
  end

  it 'should raise exception for ubuntu' do
    stub_the.node { {platform: 'ubuntu' } }
    mock_the.raise('Ubuntu not supported')

    run_recipe 'rsyslog'
  end

  it 'should create the download script' do
    stub_the.not_if
    mock_the.template("#{ruby_scripts_dir}/download_rsyslog.rb")

    run_recipe 'rsyslog'
  end

  it 'should run the download script' do
    stub_the.not_if
    mock_the.powershell('Download rsyslog').yields
    mock_the.source "ruby #{ruby_scripts_dir}/download_rsyslog.rb"

    run_recipe 'rsyslog'
  end

  it 'should unzip the downloaded installer' do
    stub_the.not_if
    stub_the.action
    mock_the.windows_zipfile('/installs/rsyslogwa').yields
    mock_the.source '/installs/rsyslogwa.zip'

    run_recipe 'rsyslog'
  end

  it 'should run the installer' do
    stub_the.not_if
    mock_the.powershell('Install rsyslog').yields
    mock_the.source 'c:\\installs\\rsyslogwa\\rsyslogwa.exe -i /S /v /qn'

    run_recipe 'rsyslog'
  end

  it 'should setup startup type' do
    mock_the.powershell('Set service startup type').yields
    mock_the.source 'Set-Service "RSyslogWindowsAgent" -startupType manual'

    run_recipe 'rsyslog'
  end
end