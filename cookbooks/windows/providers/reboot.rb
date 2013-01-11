action :none do
  system('shutdown /r')
  @new_resource.updated_by_last_action(true)
end