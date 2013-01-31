Chef::Log.info("I am in #{cookbook_name}::#{recipe_name}")

class Chef::Resource::Powershell
  def source(arg)
    code(arg)
  end
end
