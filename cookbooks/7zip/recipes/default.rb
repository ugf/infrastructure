Chef::Log.info("I am in #{cookbook_name}::#{recipe_name}")

class Chef::Resource
  include DetectVagrant
end

class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

installs_directory = 'c:/installs'

Dir.mkdir(installs_directory) unless File.exist?(installs_directory)

cookbook_file "#{installs_directory}/7z465.exe" do
  source '7z465.exe'
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

emit_marker :end

