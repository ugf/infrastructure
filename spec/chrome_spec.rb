require 'spec_helper'

describe 'chrome' do

  app = 'GoogleChromeStandaloneEnterprise.msi'
  dir = 'c:\\installs'
  path = "#{dir}\\#{app}"

  before :each do
    stub_all
  end

  it 'should copy the installer' do

    mock_the.cookbook_file(path).yields
    mock_the.source app
    stub_the.not_if

    run_recipe 'chrome'
  end

  it 'should disable auto updates' do

    key = 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Update'

    mock_the.windows_registry(key).yields
    mock_the.values 'AutoUpdateCheckPeriodMinutes' => '0'

    run_recipe 'chrome'
  end

  it 'should set default options' do

    key = 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome'

    mock_the.windows_registry(key).yields
    mock_the.values(
      'HomepageIsNewTabPage' => 1,
      'RestoreOnStartup' => 0,
      'DefaultBrowserSettingEnabled' => 0,
      'DefaultSearchProviderEnabled' => 0
    )

    run_recipe 'chrome'
  end

  it 'should install' do

    stub_the.powershell.yields
    stub_the.not_if

    mock_the.source "Msiexec /q /I #{path}"

    run_recipe 'chrome'
  end
end