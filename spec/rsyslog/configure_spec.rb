require_relative '../spec_helper'

describe 'rsyslog configure' do
  let(:agent_dir) { "#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent" }

  before :each do
    stub_the.rightscale_marker
    stub_the.template
    stub_the.powershell
    stub_the.node { { platform: 'windows' } }
  end

  it 'should raise exception for ubuntu' do
    stub_the.node { {platform: 'ubuntu' } }
    mock_the.raise('Ubuntu not supported')

    run_recipe 'rsyslog', 'configure'
  end

  it 'should create settings file' do
    mock_the.template("#{agent_dir}\\settings.reg")

    run_recipe 'rsyslog', 'configure'
  end

  it 'should import rsyslog settings' do
    mock_the.powershell('Import rsyslog settings').yields
    mock_the.source "regedit /s \"#{agent_dir}\\settings.reg\""

    run_recipe 'rsyslog', 'configure'
  end

  it 'should start service' do
    mock_the.powershell('Start service').yields
    expected_commands = [
      'Set-Service "RSyslogWindowsAgent" -startupType automatic',
      'Restart-Service "RSyslogWindowsAgent"'
    ]
    mock_the.source(argument_satisfies do |script|
      script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
    end
    )

    run_recipe 'rsyslog', 'configure'
  end
end