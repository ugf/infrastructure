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

require_relative 'play_doh'

def mock_the
  mock main
end

def stub_the
  stub main
end

def stub_all
  #[:emit_marker, :include_recipe, :template, :execute,
  # :windows_zipfile, 0:windows_task, :cookbook_file,
  # :powershell, :env, :rightscale_marker, :windows_registry].
  #    each { |method| stub_the.call method}
  stub_the.emit_marker
  stub_the.include_recipe
  stub_the.template
  stub_the.execute
  stub_the.windows_zipfile
  stub_the.windows_task
  stub_the.cookbook_file
  stub_the.powershell
  stub_the.env
  stub_the.rightscale_marker
  stub_the.windows_registry
end

