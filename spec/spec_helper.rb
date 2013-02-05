require 'rr'
require 'rspec'
require 'chef_stub'

RSpec.configure do |c|
  c.mock_framework = :rr
  c.alias_it_should_behave_like_to :containing, 'containing'
end

module RR::Adapters::RRMethods
  def argument_satisfies(&block)
    RR::WildcardMatchers::Satisfy.new(block)
  end
end

def root_dir
  File.join(File.dirname(__FILE__), '..')
end

def run_recipe(cookbook, recipe='default')
  load "#{root_dir}/cookbooks/#{cookbook}/recipes/#{recipe}.rb"
end

def main
  @main ||= TOPLEVEL_BINDING.eval 'self'
end

def mock_the
  mock main
end

def stub_the
  stub main
end

