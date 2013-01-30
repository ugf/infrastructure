require_relative '../spec_helper'

main = self

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
    stub(main).emit_marker
    stub(main).include_recipe
  end

  context 'when platform is ubuntu' do

    before :each do
      stub(main).template
      stub(main).directory
      stub(main).ruby_block
      stub(main).bash
      stub(main).package
      stub(main).file
      stub(main).execute
      stub(main).link
      stub(main).node { { ruby_scripts_dir: '/rubyscripts', platform: 'ubuntu' } }
    end

    it 'should create the download script' do
      mock(main).template("#{ruby_scripts_dir}/download_ruby.rb")

      run_recipe 'ruby'
    end

    it 'should delete and create the source directory' do
      stub(main).recursive
      stub(main).only_if
      mock(main).directory(source_dir).yields
      mock(main).action :delete

      stub(main).mode
      mock(main).directory(source_dir).yields
      mock(main).action :create

      run_recipe 'ruby'
    end

    it 'should install fog' do
      stub(main).not_if
      mock(main).ruby_block('Install fog').yields
      mock(main).block.yields
      mock(main).system '/opt/rightscale/sandbox/bin/gem install fog -v 1.1.1 --no-rdoc --no-ri'

      run_recipe 'ruby'
    end

    it 'should download ruby' do
      stub(main).not_if
      mock(main).bash('Download ruby').yields
      expected_commands = [
        "/opt/rightscale/sandbox/bin/ruby -rubygems #{ruby_scripts_dir}/download_ruby.rb",
        "unzip -d #{source_dir} #{source_dir}.zip"
      ]

      mock(main).code(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should unzip ruby artifact' do
      stub(main).only_if
      mock(main).bash('Unzip ruby artifact').yields
      expected_commands = [
        "if [ ! -d #{source_dir} ]; then mkdir -p #{source_dir}; fi",
        "unzip -d #{source_dir} /vendor_artifacts/ruby/#{ruby_version}/ruby.zip"
      ]

      mock(main).code(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should install ruby packages' do
      ruby_packages = ['libreadline-dev', 'libssl-dev', 'libyaml-dev', 'libffi-dev', 'libncurses-dev', 'libdb-dev' ,
        'libgdbm-dev', 'tk-dev']
      ruby_packages.each do |name|
        mock(main).package name
      end

      run_recipe 'ruby'
    end
  end

  context 'when platform is windows' do

    before :each do
      stub(main).template
      stub(main).powershell
      stub(main).windows_zipfile
      stub(main).node { { ruby_scripts_dir: '/rubyscripts', platform: 'windows' } }
    end

    it 'should create the download script' do
      stub(main).not_if
      mock(main).template("#{ruby_scripts_dir}/download_ruby.rb")

      run_recipe 'ruby'
    end

    it 'should install fog and run the download script' do
      stub(main).not_if
      mock(main).powershell('Install fog and download ruby').yields
      expected_commands = [
        'cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"',
        'cmd /c gem install fog -v 1.1.1 --no-rdoc --no-ri',
        'cmd /c ruby -rubygems c:\\rubyscripts\\download_ruby.rb'
      ].collect { |x| x.gsub(/\\/, '\\\\\\') }

      mock(main).source(argument_satisfies do |script|
        script.split("\n").collect { |x| x.strip unless x.empty? }.compact == expected_commands
      end
      )

      run_recipe 'ruby'
    end

    it 'should unzip the downloaded installer' do
      stub(main).not_if
      stub(main).action
      mock(main).windows_zipfile('/installs/ruby_windows').yields
      mock(main).source '/installs/ruby_windows.zip'

      run_recipe 'ruby'
    end

    it 'should run the installer' do
      stub(main).not_if
      mock(main).powershell('Install ruby').yields
      mock(main).source 'c:\\installs\\ruby_windows\\rubyinstaller-1.9.2-p0.exe /tasks=modpath /silent'

      run_recipe 'ruby'
    end
  end
end