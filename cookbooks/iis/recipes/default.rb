rightscale_marker :begin

['IIS-WebServer', 'IIS-WebServerRole'].each do |feature|
  windows_feature feature do
    action :install
  end
end

rightscale_marker :end