require 'rake'

rightscale_marker :begin

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end

def replace_text_in_files(list, source, target)
  list.each { |file| replace_text_in_file(file, source, target) }
end

def replace_text_in_file(file, source, target)
  text = File.read(file)
  modified = text.gsub(/#{source}/, "#{target}")
  File.open(file, 'w') { |f| f.puts(modified) }
end

ruby_block 'Updating config files' do
  block do
    configs = FileList["#{node[:binaries_directory]}/**/*.config"]
    puts "found #{configs.count} config files"

    replace_text_in_files(configs, 'Data Source=.*?;', "Data Source=#{node[:newgen][:database_server]};")
    replace_text_in_files(configs, 'Integrated Security=SSPI', "Integrated Security=false;User Id=#{node[:newgen][:database_user]};Password=#{node[:newgen][:database_password]}")
  end
end


rightscale_marker :end