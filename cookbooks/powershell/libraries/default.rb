
Chef::Log.info("I am in patch")

class Powershell < Chef::Resource
  alias :source :code
end

