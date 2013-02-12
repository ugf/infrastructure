require 'rr'

def play_doh(sut=nil)
  return sut if sut.is_a? Playdoh
  Playdoh.new sut
end

module Mock

  extend RR::Adapters::RRMethods

  def self.reset(sut, method)
    RR::Space.instance.reset_double sut, method
  end

end

module Meta

  DATA_TYPES = [
    String, Symbol, Regexp,
    Float, Fixnum, Bignum,
    TrueClass, FalseClass,
    Array, Hash,
    Exception
  ]

  def instance_methods
    @sut.public_methods(false)
    .reject { |m| is_property? m }
    .map &:to_sym
  end

  def is_dependency?(object)
    object != @sut and
      not DATA_TYPES.include? object.class
  end

  def is_property?(name)
    @sut.instance_variables.
      include? property_for_method name
  end

  def property_for_method(name)
    "@#{name.to_s}".to_sym
  end

  def method_for_property(name)
    name.to_s[1..-1].to_sym
  end

end

module Stub

  include Meta

  def stub(method, value=nil)
    Mock.stub(@sut, method).returns(value)
  end

  def stub_methods
    instance_methods.each { |m| stub m }
    stub_method_missing
  end

  def stub_method_missing
    def @sut.method_missing(method, *args)
      nil
    end
  end

  def stub_dependencies
    @sut.instance_variables.each { |v| stub_dependency v }
  end

  def stub_dependency(name)
    current_value = @sut.instance_variable_get name
    return unless is_dependency? current_value

    stubbed_value = play_doh current_value

    @sut.instance_variable_set name, stubbed_value
    stub method_for_property(name), stubbed_value
  end

end

class Playdoh

  include Stub

  def initialize(sut=nil)
    @sut = sut || Object.new
    stub_methods
    stub_dependencies
    default_operation
  end

  def operation
    @operation = -> method, *args { yield method, *args }
    self
  end

  def default_operation
    operation do |method, *args|
      @sut.send method, *args
    end
  end

  def method_missing(method, *args)
    @operation.call method, *args
  ensure
    default_operation
  end

  def reset(method)
    Mock.reset @sut, method
  end

  def given
    Mock.stub @sut
  end

  def when
    operation do |method, *args|
      reset method
      @sut.send method, *args
    end
  end

  def verify
    Mock.mock @sut
  end

end