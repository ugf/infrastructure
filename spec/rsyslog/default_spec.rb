require_relative '../spec_helper'

main = self

describe 'rsyslog' do
  recipe = -> { load '../cookbooks/rsyslog/recipes/default.rb' }
  let(:ruby_scripts_dir) { '/rubyscripts' }

  before :each do
    stub(main).rightscale_marker
    stub(main).include_recipe
    stub(main).template
    stub(main).powershell
    stub(main).windows_zipfile
    stub(main).node { { ruby_scripts_dir: '/rubyscripts' } }
  end

  it 'should raise exception for ubuntu' do
    stub(main).node { {platform: 'ubuntu' } }
    mock(main).raise('Ubuntu not supported')

    recipe.call
  end

  it 'should create the download script' do
    stub(main).not_if
    mock(main).template("#{ruby_scripts_dir}/download_rsyslog.rb")

    recipe.call
  end

  it 'should run the download script' do
    stub(main).not_if
    mock(main).powershell('Download rsyslog').yields
    mock(main).source "ruby #{ruby_scripts_dir}/download_rsyslog.rb"

    recipe.call
  end

  it 'should unzip the downloaded installer' do
    stub(main).not_if
    stub(main).action
    mock(main).windows_zipfile('/installs/rsyslogwa').yields
    mock(main).source '/installs/rsyslogwa.zip'

    recipe.call
  end

  it 'should run the installer' do
    stub(main).not_if
    mock(main).powershell('Install rsyslog').yields
    mock(main).source 'c:\\installs\\rsyslogwa\\rsyslogwa.exe -i /S /v /qn'

    recipe.call
  end

  it 'should setup startup type' do
    mock(main).powershell('Set service startup type').yields
    mock(main).source 'Set-Service "RSyslogWindowsAgent" -startupType manual'

    recipe.call
  end
end