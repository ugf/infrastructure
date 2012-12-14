rightscale_marker :begin

#feature_list = [
#  'IIS-WebServerRole',
#  'IIS-WebServer',
#  'IIS-WebServerManagementTools',
#  'IIS-ApplicationDevelopment',
#  'IIS-ASPNET',
#  'IIS-CGI',
#  'IIS-ClientCertificateMappingAuthentication',
#  'IIS-CommonHttpFeatures',
#  'IIS-CustomLogging',
#  'IIS-DefaultDocument',
#  'IIS-DigestAuthentication',
#  'IIS-DirectoryBrowsing',
#  'IIS-HealthAndDiagnostics',
#  'IIS-HostableWebCore',
#  'IIS-HttpCompressionDynamic',
#  'IIS-HttpCompressionStatic',
#  'IIS-HttpErrors',
#  'IIS-HttpLogging',
#  'IIS-HttpRedirect',
#  'IIS-HttpTracing',
#  'IIS-IIS6ManagementCompatibility',
#  'IIS-IISCertificateMappingAuthentication',
#  'IIS-IPSecurity',
#  'IIS-ISAPIExtensions',
#  'IIS-ISAPIFilter',
#  'IIS-LegacyScripts',
#  'IIS-LegacySnapIn',
#  'IIS-LoggingLibraries',
#  'IIS-ManagementConsole',
#  'IIS-ManagementScriptingTools',
#  'IIS-ManagementService',
#  'IIS-Metabase',
#  'IIS-NetFxExtensibility',
#  'IIS-ODBCLogging',
#  'IIS-Performance',
#  'IIS-RequestFiltering',
#  'IIS-RequestMonitor',
#  'IIS-Security',
#  'IIS-ServerSideIncludes',
#  'IIS-StaticContent',
#  'IIS-URLAuthorization',
#  'IIS-WebDAV',
#  'IIS-WindowsAuthentication',
#  'IIS-WMICompatibility',
#  'WAS-ConfigurationAPI',
#  'WAS-NetFxEnvironment',
#  'WAS-ProcessModel',
#  'WAS-WindowsActivationService'
#
#]

#windows_feature 'Install IIS' do
#  features feature_list
#  action :install
#end

powershell 'Install IIS' do
  source("dism.exe /online /enable-feature /featurename:IIS-WebServerRole /featurename:IIS-WebServer /featurename:IIS-WebServerManagementTools /featurename:IIS-ApplicationDevelopment /featurename:IIS-ASPNET /featurename:IIS-CGI /featurename:IIS-ClientCertificateMappingAuthentication /featurename:IIS-CommonHttpFeatures /featurename:IIS-CustomLogging /featurename:IIS-DefaultDocument /featurename:IIS-DigestAuthentication /featurename:IIS-DirectoryBrowsing /featurename:IIS-HealthAndDiagnostics /featurename:IIS-HostableWebCore /featurename:IIS-HttpCompressionDynamic /featurename:IIS-HttpCompressionStatic /featurename:IIS-HttpErrors /featurename:IIS-HttpLogging /featurename:IIS-HttpRedirect /featurename:IIS-HttpTracing /featurename:IIS-IIS6ManagementCompatibility /featurename:IIS-IISCertificateMappingAuthentication /featurename:IIS-IPSecurity /featurename:IIS-ISAPIExtensions /featurename:IIS-ISAPIFilter /featurename:IIS-LegacyScripts /featurename:IIS-LegacySnapIn /featurename:IIS-LoggingLibraries /featurename:IIS-ManagementConsole /featurename:IIS-ManagementScriptingTools /featurename:IIS-ManagementService /featurename:IIS-Metabase /featurename:IIS-NetFxExtensibility /featurename:IIS-ODBCLogging /featurename:IIS-Performance /featurename:IIS-RequestFiltering /featurename:IIS-RequestMonitor /featurename:IIS-Security /featurename:IIS-ServerSideIncludes /featurename:IIS-StaticContent /featurename:IIS-URLAuthorization /featurename:IIS-WebDAV /featurename:IIS-WindowsAuthentication /featurename:IIS-WMICompatibility /featurename:WAS-ConfigurationAPI /featurename:WAS-NetFxEnvironment /featurename:WAS-ProcessModel /featurename:WAS-WindowsActivationService /norestart")
end

rightscale_marker :end