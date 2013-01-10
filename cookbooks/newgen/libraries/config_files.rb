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
    replace_text_in_files(configs, 'http://localhost', "http://#{node[:newgen][:application_server]}")
  end

end