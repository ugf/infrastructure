require_relative '../spec_helper'

module DetectVagrant
end

module Chef
  class Resource
  end
  class Recipe
  end
end

describe 'ruby' do
  let(:ruby_scripts_dir) { '/rubyscripts' }
  let(:ruby_version) { '1.9.2-p320' }
  let(:install_dir) { '/opt/ruby' }
  let(:source_dir) { '/tmp/src/ruby' }

  before :each do
    stub_the.emit_marker
    stub_the.include_recipe
  end

  context 'when platform is ubuntu' do

    before :each do
      stub_the.log
      stub_the.template
      stub_the.directory
      stub_the.ruby_block
      stub_the.bash
      stub_the.package
      stub_the.file
      stub_the.execute
      stub_the.link
      stub_the.node { { ruby_scripts_dir: '/rubyscripts', platform: 'ubuntu' } }
    end

    it 'should create the download script' do
      mock_the.template("#{ruby_scripts_dir}/download_ruby.rb")

      run_recipe 'ruby'
    end

    it 'should delete and create the source directory' do
      stub_the.recursive
      stub_the.only_if
      mock_the.directory(source_dir).yields
      mock_the.action :delete

      stub_the.mode
      mock_the.directory(source_dir).yields
      mock_the.action :create

      run_recipe 'ruby'
    end

    it 'should install fog' do
      stub_the.not_if
      mock_the.ruby_block('Install fog').yields
      mock_the.block.yields
      mock_the.system '/opt/rightscale/sandbox/bin/gem install fog -v 1.1.1 --no-rdoc --no-ri'

      run_recipe 'ruby'
    end

    it 'should download ruby' do
      stub_the.not_if
      mock_the.bash('Download ruby').yields
      expected_commands = [
        "/opt/rightscale/sandbox/bin/ruby -rubygems #{ruby_scripts_dir}/download_ruby.rb",
        "unzip -d #{source_dir} #{source_dir}.zip"
      ]

      mock_the.code(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should unzip ruby artifact' do
      stub_the.only_if
      mock_the.bash('Unzip ruby artifact').yields
      expected_commands = [
        "if [ ! -d #{source_dir} ]; then mkdir -p #{source_dir}; fi",
        "unzip -d #{source_dir} /vendor_artifacts/ruby/#{ruby_version}/ruby.zip"
      ]

      mock_the.code(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should install ruby packages' do
      ruby_packages = ['libreadline-dev', 'libssl-dev', 'libyaml-dev', 'libffi-dev', 'libncurses-dev', 'libdb-dev' ,
        'libgdbm-dev', 'tk-dev']
      ruby_packages.each do |name|
        mock_the.package name
      end

      run_recipe 'ruby'
    end

    it 'should change permissions for configure and ifchange' do
      mock_the.file("#{source_dir}/configure").yields
      mock_the.mode 00777
      mock_the.file("#{source_dir}/tool/ifchange").yields
      mock_the.mode 00777

      run_recipe 'ruby'
    end

    it 'should run configure' do
      mock_the.execute('configure').yields
      mock_the.command "./configure --enable-shared --prefix=#{install_dir}/#{ruby_version}"
      mock_the.cwd source_dir

      run_recipe 'ruby'
    end

    it 'should run all make commands' do
      make_commands = ['all', 'test', 'install']
      make_commands.each do |cmd|
        mock_the.execute("make #{cmd}").yields
        mock_the.command "make #{cmd}"
        mock_the.cwd source_dir
      end

      run_recipe 'ruby'
    end

    it 'should delete active link' do
      stub_the.only_if
      mock_the.link("#{install_dir}/active").yields
      mock_the.action :delete

      run_recipe 'ruby'
    end

    it 'should create sym link' do
      mock_the.execute('create sym link').yields
      mock_the.command "ln -fs #{ruby_version} active"
      mock_the.cwd install_dir

      run_recipe 'ruby'
    end

    it 'should delete and soft link the executables' do
      executables = ['ruby', 'gem', 'rake', 'rspec', 'rdoc', 'ri', 'bundle', 'cucumber', 'rails']

      executables.each do |exe|
        mock_the.file("/usr/bin/#{exe}").yields
        mock_the.action :delete
      end

      executables.each do |exe|
        mock_the.link("/usr/bin/#{exe}").yields
        mock_the.to "#{install_dir}/active/bin/#{exe}"
      end

      run_recipe 'ruby'
    end
  end

  context 'when platform is windows' do

    before :each do
      stub_the.template
      stub_the.powershell
      stub_the.windows_zipfile
      stub_the.node { { ruby_scripts_dir: '/rubyscripts', platform: 'windows' } }
    end

    it 'should create the download script' do
      stub_the.not_if
      mock_the.template("#{ruby_scripts_dir}/download_ruby.rb")

      run_recipe 'ruby'
    end

    it 'should install fog and run the download script' do
      stub_the.not_if
      mock_the.powershell('Install fog and download ruby').yields
      expected_commands = [
        'cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"',
        'cmd /c gem install fog -v 1.1.1 --no-rdoc --no-ri',
        'cmd /c ruby -rubygems c:\\rubyscripts\\download_ruby.rb'
      ].collect { |x| x.gsub(/\\/, '\\\\\\') }

      mock_the.source(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should unzip the downloaded installer' do
      stub_the.not_if
      stub_the.action
      mock_the.windows_zipfile('/installs/ruby_windows').yields
      mock_the.source '/installs/ruby_windows.zip'

      run_recipe 'ruby'
    end

    it 'should run the installer' do
      stub_the.not_if
      mock_the.powershell('Install ruby').yields
      mock_the.source 'c:\\installs\\ruby_windows\\rubyinstaller-1.9.2-p0.exe /tasks=modpath /silent'

      run_recipe 'ruby'
    end
  end
end