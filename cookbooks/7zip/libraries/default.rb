Chef::Log.info("I am in patch")

class Chef::Resource::Powershell
  def source(arg)
    code(arg)
  end
  #alias :source :code
end

