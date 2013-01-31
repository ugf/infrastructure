Chef::Log.info("I am in patch")

class Chef::Resource::Powershell
  alias :source :code
end
