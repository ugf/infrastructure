action :install do
  raise 'Could not find msi' unless ::File.exist?(@new_resource.source)

  Chef::Log.debug("msiexec /i #{@new_resource.source} /qn")

  `msiexec /i "#{@new_resource.source}" /qn #{@new_resource.options}`

  @new_resource.updated_by_last_action(true)
end