require 'spec_helper'

describe 'jdk' do

  before :each do
    stub_the.rightscale_marker
    stub_the.include_recipe
    stub_the.template
  end

  context 'When the platform is windows' do
    let(:download_directory) { '/download_jdk' }
    let(:artifact) { 'jdk_windows' }

    before :each do
      stub_the.powershell
      stub_the.windows_zipfile
      stub_the.node { {platform: 'windows', ruby_scripts_dir: '/ruby192' } }
      stub_the.source
      stub(File).exist?
      stub_the.env
    end

    it 'the installer is downloaded' do
      stub_the.not_if
      stub_the.powershell.yields

      mock_the.source 'ruby /ruby192/download_jdk.rb'

      run_recipe 'jdk'
    end

    it 'the installer is not download twice' do
      stub_the.source
      stub_the.not_if.yields
      stub_the.powershell.yields

      mock(File).exist?("#{download_directory}/#{artifact}.zip") { true }

      run_recipe 'jdk'
    end

    it 'the installer is unzipped' do
      stub_the.not_if
      stub_the.action

      mock_the.windows_zipfile("#{download_directory}/#{artifact}").yields
      mock_the.source("#{download_directory}/#{artifact}.zip")

      run_recipe 'jdk'
    end

    it 'sets environment variables to the install directory' do
      stub_the.action
      stub_the.delim

      mock_the.env('JAVA_HOME').yields
      mock_the.env('JRE_HOME').yields
      mock_the.value('c:\jdk').times(2)

      mock_the.env('PATH').yields
      mock_the.value 'c:\jdk\bin'

      run_recipe 'jdk'
    end
  end
end