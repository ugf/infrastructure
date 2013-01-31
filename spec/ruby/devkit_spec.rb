require_relative '../spec_helper'

describe 'ruby devkit' do
  let(:ruby_scripts_dir) { '/rubyscripts' }

  before :each do
    stub_the.include_recipe
    stub_the.template
    stub_the.powershell
    stub_the.windows_zipfile
    stub_the.execute
    stub_the.node { { ruby_scripts_dir: '/rubyscripts', platform: 'windows' } }
  end

  it 'should create the download script' do
    stub_the.not_if
    mock_the.template("#{ruby_scripts_dir}/download_devkit.rb")

    run_recipe 'ruby', 'devkit'
  end

  it 'should run the download script' do
    stub_the.not_if
    mock_the.powershell('Download devkit').yields
    expected_commands = [
      'cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"',
      'cmd /c ruby -rubygems c:\\rubyscripts\\download_devkit.rb'
    ].collect { |x| x.gsub(/\\/, '\\\\\\') }

    mock_the.source(argument_satisfies do |script|
      script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
    end
    )

    run_recipe 'ruby', 'devkit'
  end

  it 'should unzip the downloaded artifact' do
    stub_the.not_if
    mock_the.windows_zipfile('/installs/devkit').yields
    mock_the.source '/installs/devkit.zip'
    mock_the.action :unzip

    run_recipe 'ruby', 'devkit'
  end

  it 'should extract from the executable' do
    stub_the.not_if
    mock_the.windows_zipfile('/devkit').yields
    mock_the.source '/installs/devkit/devkit.exe'
    mock_the.action :unzip

    run_recipe 'ruby', 'devkit'
  end

  it 'should initialize devkit' do
    mock_the.execute('Initializing devkit').yields
    mock_the.command 'ruby dk.rb init'
    mock_the.cwd '/devkit'

    run_recipe 'ruby', 'devkit'
  end

  it 'should install devkit' do
    mock_the.execute('Installing devkit').yields
    mock_the.command 'ruby dk.rb install'
    mock_the.cwd '/devkit'

    run_recipe 'ruby', 'devkit'
  end
end