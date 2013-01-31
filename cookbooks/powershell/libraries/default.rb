Chef::Log.info("I am in patch")

class Chef::Resource::Powershell
  alias_method :source, :code
end
