actions :install

attribute :source, :kind_of => String
attribute :options, :kind_of => String

def initialize(name, run_context=nil)
  super
  @action = :install
end