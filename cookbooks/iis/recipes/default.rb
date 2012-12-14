rightscale_marker :begin

feature_list = [
  'IIS-WebServerRole',
  'IIS-WebServer',
  'IIS-WebServerManagementTools',
  'IIS-ApplicationDevelopment',
  'IIS-ASPNET',
  'IIS-CGI',
  'IIS-ClientCertificateMappingAuthentication',
  'IIS-CommonHttpFeatures',
  'IIS-CustomLogging',
  'IIS-DefaultDocument',
  'IIS-DigestAuthentication',
  'IIS-DirectoryBrowsing',
  'IIS-HealthAndDiagnostics',
  'IIS-HostableWebCore',
  'IIS-HttpCompressionDynamic',
  'IIS-HttpCompressionStatic',
  'IIS-HttpErrors',
  'IIS-HttpLogging',
  'IIS-HttpRedirect',
  'IIS-HttpTracing',
  'IIS-IIS6ManagementCompatibility',
  'IIS-IISCertificateMappingAuthentication',
  'IIS-IPSecurity',
  'IIS-ISAPIExtensions',
  'IIS-ISAPIFilter',
  'IIS-LegacyScripts',
  'IIS-LegacySnapIn',
  'IIS-LoggingLibraries',
  'IIS-ManagementConsole',
  'IIS-ManagementScriptingTools',
  'IIS-ManagementService',
  'IIS-Metabase',
  'IIS-NetFxExtensibility',
  'IIS-ODBCLogging',
  'IIS-Performance',
  'IIS-RequestFiltering',
  'IIS-RequestMonitor',
  'IIS-Security',
  'IIS-ServerSideIncludes',
  'IIS-StaticContent',
  'IIS-URLAuthorization',
  'IIS-WebDAV',
  'IIS-WindowsAuthentication',
  'IIS-WMICompatibility',
  'WAS-ConfigurationAPI',
  'WAS-NetFxEnvironment',
  'WAS-ProcessModel',
  'WAS-WindowsActivationService'

]

windows_feature 'Install IIS' do
  features feature_list
  action :install
end


rightscale_marker :end