require_relative '../spec_helper'

main = self

describe 'ruby devkit' do
  let(:ruby_scripts_dir) { '/rubyscripts' }

  before :each do
    stub(main).include_recipe
    stub(main).template
    stub(main).powershell
    stub(main).windows_zipfile
    stub(main).execute
    stub(main).node { { ruby_scripts_dir: '/rubyscripts', platform: 'windows' } }
  end

  it 'should create the download script' do
    stub(main).not_if
    mock(main).template("#{ruby_scripts_dir}/download_devkit.rb")

    run_recipe 'ruby', 'devkit'
  end

  it 'should run the download script' do
    stub(main).not_if
    mock(main).powershell('Download devkit').yields
    expected_commands = [
      'cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"',
      'cmd /c ruby -rubygems c:\\rubyscripts\\download_devkit.rb'
    ].collect { |x| x.gsub(/\\/, '\\\\\\') }

    mock(main).source(argument_satisfies do |script|
      script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
    end
    )

    run_recipe 'ruby', 'devkit'
  end

  it 'should unzip the downloaded artifact' do
    stub(main).not_if
    mock(main).windows_zipfile('/installs/devkit').yields
    mock(main).source '/installs/devkit.zip'
    mock(main).action :unzip

    run_recipe 'ruby', 'devkit'
  end

  it 'should extract from the executable' do
    stub(main).not_if
    mock(main).windows_zipfile('/devkit').yields
    mock(main).source '/installs/devkit/devkit.exe'
    mock(main).action :unzip

    run_recipe 'ruby', 'devkit'
  end

  it 'should initialize devkit' do
    mock(main).execute('Initializing devkit').yields
    mock(main).command 'ruby dk.rb init'
    mock(main).cwd '/devkit'

    run_recipe 'ruby', 'devkit'
  end

  it 'should install devkit' do
    mock(main).execute('Installing devkit').yields
    mock(main).command 'ruby dk.rb install'
    mock(main).cwd '/devkit'

    run_recipe 'ruby', 'devkit'
  end
end