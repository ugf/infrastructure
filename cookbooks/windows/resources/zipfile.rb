actions :unzip

attribute :path, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String

def initialize(name, run_context=nil)
  super
  @action = :unzip
end
