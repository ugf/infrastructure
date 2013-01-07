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
    copy migration\\migrate* main_website\\bin /y
    cd main_website\\bin
    migrate.ci.with.username.bat #{node[:newgen][:database_server]} #{node[:newgen][:database_user]} #{node[:newgen][:database_password]}
  EOF
  cwd "#{node[:binaries_directory]}"
end

#powershell '' do
#  parameters({
#    'POWERSHELL_SCRIPTS_DIR' => "c:#{node[:powershell_scripts_dir].gsub('/','\\')}",
#    'BINARIES_DIRECTORY' => "c:#{node[:binaries_directory].gsub('/','\\')}"
#  })
#  script = <<-EOF
#Import-Module '$env:POWERSHELL_SCRIPTS_DIR\\deploy_website.ps1'
#
#deploy_website 'main website' 'main_website' '$env:BINARIES_DIRECTORY\\main_website' ':55555:'
#deploy_website 'sts website' 'sts_website' '$env:BINARIES_DIRECTORY\\sts_website' ':55556:'
#  EOF
#  source(script)
#end

rightscale_marker :end