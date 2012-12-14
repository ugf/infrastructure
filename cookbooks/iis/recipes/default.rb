rightscale_marker :begin

def feature_list
  "/featurename:" + [
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
  ].join(' /featurename:')
end

powershell 'Install IIS' do
  source("dism.exe /online /enable-feature #{feature_list} /norestart")
end

rightscale_marker :end