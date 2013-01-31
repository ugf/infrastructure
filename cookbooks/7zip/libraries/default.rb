require 'chef/resource'

class Chef::Resource::Powershell
  def source(arg)
    code(arg)
  end
end