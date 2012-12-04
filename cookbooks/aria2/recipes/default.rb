rightscale_marker :begin

cookbook_file 'c:/installs/aria2.zip' do
  source 'aria2.zip'
end

windows_zipfile 'c:/aria2' do
  source 'c:/installs/aria2.zip'
  action :unzip
end

rightscale_marker :end

