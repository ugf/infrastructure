
Chef::Log.info("I am in patch")

module Powershell < Chef::Resource
  alias :source :code
end

