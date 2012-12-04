rightscale_marker :begin

installs_directory = 'c:/installs'

Dir.mkdir(installs_directory) unless File.exist? installs_directory

cookbook_file "#{installs_directory}/aria2.zip" do
  source 'aria2.zip'
end

windows_zipfile 'c:/aria2' do
  source "#{installs_directory}/aria2.zip"
  action :unzip
end

rightscale_marker :end

