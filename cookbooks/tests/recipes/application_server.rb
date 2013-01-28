ruby_block 'Running tests' do
  block do
    require 'rubygems'
    require 'cucumber'
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:default) do |t|
      t.cucumber_opts = ". --format pretty --tags @application_server"
    end
  end
end
