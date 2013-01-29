require 'rr'
require 'rspec'

RSpec.configure do |c|
  c.mock_framework = :rr
  c.alias_it_should_behave_like_to :containing, 'containing'
end

module RR::Adapters::RRMethods
  def argument_satifies(&block)
    RR::WildcardMatchers::Satisfy.new(block)
  end
end