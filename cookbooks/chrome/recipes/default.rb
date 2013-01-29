rightscale_marker :begin

installs_directory = 'c:\\installs'

Dir.mkdir(installs_directory) unless File.exist?(installs_directory)

cookbook_file "#{installs_directory}\\GoogleChromeStandaloneEnterprise.msi" do
  source 'GoogleChromeStandaloneEnterprise.msi'
  not_if { File.exist?("#{installs_directory}\\GoogleChromeStandaloneEnterprise.msi") }
end

windows_registry 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Update' do
  values 'AutoUpdateCheckPeriodMinutes' => '0'
end

windows_registry 'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome' do
  values(
    'HomepageIsNewTabPage' => 1,
    'RestoreOnStartup' => 0,
    'DefaultBrowserSettingEnabled' => 0,
    'DefaultSearchProviderEnabled' => 0
  )
end

powershell 'Installing chrome' do
  source("Msiexec /q /I #{installs_directory}\\GoogleChromeStandaloneEnterprise.msi")
  not_if { File.exist?("#{ENV['PROGRAMFILES(X86)']}\\Google\\Chrome") }
end

rightscale_marker :end