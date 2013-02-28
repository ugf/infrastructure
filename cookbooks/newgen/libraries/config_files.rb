require 'rake'

module ConfigFiles

  def replace_text_in_files(list, source, target)
    list.each { |file| replace_text_in_file(file, source, target) }
  end

  def replace_text_in_file(file, source, target)
    text = File.read(file)
    modified = text.gsub(/#{source}/, "#{target}")
    File.open(file, 'w') { |f| f.puts(modified) }
  end

  def update_database_settings(directory)
    configs = FileList["#{directory}/**/*.config"]

    replace_text_in_files(configs,
      'Data Source=.*?;',
      "Data Source=#{node[:newgen][:database_server]};"
    )
    replace_text_in_files(configs,
      'Integrated Security=SSPI',
      "Integrated Security=false;User Id=#{node[:newgen][:database_user]};Password=#{node[:newgen][:database_password]}"
    )
  end

  def update_website_settings
    configs = FileList["#{node[:websites_directory]}/**/*.config"]

    url = node[:route53][:domain].nil? || node[:route53][:domain].empty? ?
      "http://#{node[:newgen][:application_server]}" :
      "http://#{node[:route53][:prefix]}.#{node[:route53][:domain]}"

    replace_text_in_files(configs, 'http://localhost', url)
    replace_text_in_files(configs, ':55555', ':80')
    replace_text_in_files(configs, ':55556', ':81')

    replace_text_in_files(configs, 'key="searchHost" value=".*?"', 'key="searchHost" value="localhost"')
    replace_text_in_files(configs, 'key="searchPort" value=".*?"', 'key="searchPort" value="9200"')

    replace_text_in_files(configs, 'compilation debug="true".*', 'compilation debug="false" targetFramework="4.5" />')
    replace_text_in_files(configs, '<dotless minifyCss="false" cache="false" web="true" debug="true">', '<dotless minifyCss="true" cache="true" web="true" debug="false">')
    replace_text_in_files(configs, '<dotless minifyCss="false" cache="true" web="false" />', '<dotless minifyCss="true" cache="true" web="true" debug="false" />')

    config_elmah configs
  end

  def update_ui_settings
    configs = FileList["#{node[:ui_tests_directory]}/**/*.config"]
    replace_text_in_files(configs, '55555', '80')
  end

  def config_elmah(configs)

    elmah_connstr_matcher = 'name="elmah" connectionString='

    elmah_connstr = "#{elmah_connstr_matcher}\"Data Source=#{node[:elmah][:logging_server]};" +
      "Initial Catalog=HealthCheck;Integrated Security=false;" +
      "User Id=#{node[:elmah][:database_user]};Password=#{node[:elmah][:database_password]};" +
      "MultipleActiveResultSets=True\""

    replace_text_in_files(configs, "#{elmah_connstr_matcher}\".*?\"", elmah_connstr)

  end

end

class Chef
  class Resource
    include ConfigFiles
  end
end