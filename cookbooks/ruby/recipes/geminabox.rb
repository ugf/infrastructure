rightscale_marker :begin

root = '/geminabox'
data = "#{root}/data"

execute 'Setup' do
  command "mkdir -p #{data}"
  not_if { File.exist? data }
end

cookbook_file "#{root}/config.ru" do
  source 'config.ru'
end

execute 'Install' do
  command 'gem install geminabox'
end

execute 'Start' do
  command 'rackup -D'
  cwd root
end

rightscale_marker :end