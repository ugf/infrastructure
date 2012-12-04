rightscale_marker :begin

installs_directory = 'c:/installs'

Dir.mkdir(installs_directory) unless File.exist?(installs_directory)

cookbook_file "#{installs_directory}/7z465.exe" do
  source '7z465.exe'
end

windows_package '7zip' do
  source "#{installs_directory}/7z465.exe"
  action :install
end

powershell 'Installing 7zip' do
  source("cmd /c #{installs_directory}/7z465.exe /S")
  not_if { File.exist?("#{ENV['PROGRAMFILES(X86)']}\\7-zip") }
end

env('PATH') do
  action :modify
  delim ::File::PATH_SEPARATOR
  value "#{ENV['PROGRAMFILES(X86)']}\\7-zip"
end

rightscale_marker :end

