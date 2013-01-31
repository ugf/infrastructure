Chef::Log.info("I am in patch")

class Chef::Resource
  class Powershell
    alias :source :code
  end
end
