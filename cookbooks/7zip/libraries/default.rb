Chef::Log.info("I am in patch")

Chef::Log.info(Chef::Resource::Powershell.name)
class Chef::Resource::Powershell
  def source(arg)
    code(arg)
  end
  #alias :source :code
end

