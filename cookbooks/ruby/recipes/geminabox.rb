rightscale_marker :begin

root = 'c:\geminabox'
data = "#{root}\\data"
Dir.mkdir data unless File.exist? data

cookbook_file "#{root}\\config.ru" do
  source 'config.ru'
end

execute 'Install' do
  command 'gem install geminabox'
end

windows_task 'Start Gem in a Box' do
  user 'Administrator'
  password node[:windows][:administrator_password]
  command 'rackup'
  cwd root
  run_level :highest
  frequency :onstart
  action :create
end

windows_task 'Start Gem in a Box' do
  action :run
end

rightscale_marker :end