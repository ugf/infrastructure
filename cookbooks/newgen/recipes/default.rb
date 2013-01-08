rightscale_marker :begin

require 'rake'

include_recipe 'newgen::download'

execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end

ruby_block 'Copying websites' do
  block do
    FileUtils.mkdir_p(node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/main_website", node[:websites_directory])
    FileUtils.cp_r("#{node[:binaries_directory]}/sts_website", node[:websites_directory])
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

powershell 'Deploying websites' do
  parameters({
    'POWERSHELL_SCRIPTS_DIR' => "c:#{node[:powershell_scripts_dir].gsub('/', '\\')}",
    'WEBSITES_DIRECTORY' => "c:#{node[:websites_directory].gsub('/', '\\')}"
  })
  script = <<-EOF
    Import-Module "$env:POWERSHELL_SCRIPTS_DIR\\deploy_website.ps1"

    deploy_website 'main website' 'main_website' "$env:WEBSITES_DIRECTORY\\main_website" ':55555:'
    deploy_website 'sts website' 'sts_website' "$env:WEBSITES_DIRECTORY\\sts_website" ':55556:'
  EOF
  source(script)
end

rightscale_marker :end