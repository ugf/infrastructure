require_relative '../spec_helper'

main = self

describe 'rsyslog configure' do
  recipe = -> { load '../cookbooks/rsyslog/recipes/configure.rb' }
  let(:agent_dir) { "#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent" }

  before :each do
    stub(main).rightscale_marker
    stub(main).template
    stub(main).powershell
    stub(main).node { { platform: 'windows' } }
  end

  it 'should raise exception for ubuntu' do
    stub(main).node { {platform: 'ubuntu' } }
    mock(main).raise('Ubuntu not supported')

    recipe.call
  end

  it 'should create settings file' do
    mock(main).template("#{agent_dir}\\settings.reg")

    recipe.call
  end

  it 'should import rsyslog settings' do
    mock(main).powershell('Import rsyslog settings').yields
    mock(main).source "regedit /s \"#{agent_dir}\\settings.reg\""

    recipe.call
  end

  it 'should start service' do
    mock(main).powershell('Start service').yields
    expected_commands = [
      'Set-Service "RSyslogWindowsAgent" -startupType automatic',
      'Restart-Service "RSyslogWindowsAgent"'
    ]
    mock(main).source(argument_satisfies do |script|
      script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
    end
    )

    recipe.call
  end
end