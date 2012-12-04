action :unzip do
  raise '7zip is not installed' unless File.exist?("#{ENV['ProgramFiles(x86)']}/7-Zip/7z.exe")

  Chef::Log.debug("unzip #{@new_resource.source} => #{@new_resource.path}")

  `"#{ENV['ProgramFiles(x86)']}\\7-Zip\\7z.exe" x -y -o#{@new_resource.path} -r #{@new_resource.source}`

  @new_resource.updated_by_last_action(true)
end
