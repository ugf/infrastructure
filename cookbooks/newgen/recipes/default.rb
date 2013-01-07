require 'rake'

rightscale_marker :begin

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end

ruby_block 'Updating config files' do
  block do
    def replace_text_in_files(list, source, target)
      list.each { |file| replace_text_in_file(file, source, target) }
    end

    def replace_text_in_file(file, source, target)
      text = File.read(file)
      modified = text.gsub(/#{source}/, "#{target}")
      File.open(file, 'w') { |f| f.puts(modified) }
    end

    configs = FileList["#{node[:binaries_directory]}/**/*.config"]
    puts "found #{configs.count} config files"

    replace_text_in_files(configs, 'Data Source=.*?;', "Data Source=#{node[:newgen][:database_server]};")
    replace_text_in_files(configs, 'Integrated Security=SSPI', "Integrated Security=false;User Id=#{node[:newgen][:database_user]};Password=#{node[:newgen][:database_password]}")
  end
end

execute 'Run migrate' do
  command <<-EOF
    copy migration/migrate* main_website/bin
    main_website/bin/migrate.ci.with.username.bat #{node[:newgen][:database_server]} #{node[:newgen][:database_user]} #{node[:newgen][:database_password]}
  EOF
  cwd "#{node[:binaries_directory]}"
end




rightscale_marker :end