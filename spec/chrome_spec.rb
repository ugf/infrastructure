require 'spec_helper'
main = self

describe 'chrome' do

  recipe = -> { load '../cookbooks/chrome/recipes/default.rb' }
  app = 'GoogleChromeStandaloneEnterprise.msi'
  dir = 'c:\\installs'
  path = "#{dir}\\#{app}"

  before :each do
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).windows_registry
    stub(main).powershell
  end

  it 'should copy the installer' do

    mock(main).cookbook_file(path).yields
    mock(main).source app
    stub(main).not_if

    run_recipe 'chrome'
  end

  it 'should disable auto updates' do

    key = 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Update'

    mock(main).windows_registry(key).yields
    mock(main).values 'AutoUpdateCheckPeriodMinutes' => '0'

    run_recipe 'chrome'
  end

  it 'should set default options' do

    key = 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome'

    mock(main).windows_registry(key).yields
    mock(main).values(
      'HomepageIsNewTabPage' => 1,
      'RestoreOnStartup' => 0,
      'DefaultBrowserSettingEnabled' => 0,
      'DefaultSearchProviderEnabled' => 0
    )

    run_recipe 'chrome'
  end

  it 'should install' do

    stub(main).powershell.yields
    stub(main).not_if

    mock(main).source "Msiexec /q /I #{path}"

    run_recipe 'chrome'
  end
end