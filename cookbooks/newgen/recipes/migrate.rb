rightscale_marker :begin

require 'rake'

include_recipe 'newgen::download'

ruby_block 'Copying websites' do
  block do
    FileUtils.mkdir_p(node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/main_website", node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/migration/.", "#{node[:websites_directory]}/main_website/bin")
  end
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

    configs = FileList["#{node[:websites_directory]}/**/*.config"]
    puts "found #{configs.count} config files"

    replace_text_in_files(configs, 'Data Source=.*?;', "Data Source=#{node[:newgen][:database_server]};")
    replace_text_in_files(configs, 'Integrated Security=SSPI', "Integrated Security=false;User Id=#{node[:newgen][:database_user]};Password=#{node[:newgen][:database_password]}")
  end
end

execute 'Running migrate' do
  command "migrate.ci.with.username.bat #{node[:newgen][:database_server]} #{node[:newgen][:database_user]} #{node[:newgen][:database_password]}"
  cwd "#{node[:websites_directory]}/main_website/bin"
end

rightscale_marker :end