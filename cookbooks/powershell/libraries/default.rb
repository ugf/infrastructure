Chef::Log.info("I am in patch")

class Chef::Resource::Powershell
  alias_attribute :source, :code
end
