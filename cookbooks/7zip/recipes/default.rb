rightscale_marker :begin

cookbook_file 'c:/installs/7z465.exe' do
  source '7z465.exe'
end

windows_package '7zip' do
  source 'c:/installs/7z465.exe'
  action :install
end

env('PATH') do
  action :modify
  delim ::File::PATH_SEPARATOR
  value "#{ENV['PROGRAMFILES(X86)']}\\7-zip"
end

rightscale_marker :end