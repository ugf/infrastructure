require 'spec_helper'

main = self

describe 'jdk' do

  before :each do
    stub(main).rightscale_marker
    stub(main).include_recipe
    stub(main).template
  end

  context 'When the platform is windows' do
    let(:download_directory) { '/download_jdk' }
    let(:artifact) { 'jdk_windows' }

    before :each do
      stub(main).powershell
      stub(main).windows_zipfile
      stub(main).node { {platform: 'windows', ruby_scripts_dir: '/ruby192' } }
      stub(main).source
      stub(File).exist?
      stub(main).env
    end

    it 'the installer is downloaded' do
      stub(main).not_if
      stub(main).powershell.yields

      mock(main).source 'ruby /ruby192/download_jdk.rb'

      run_recipe 'jdk'
    end

    it 'the installer is not download twice' do
      stub(main).source
      stub(main).not_if.yields
      stub(main).powershell.yields

      mock(File).exist?("#{download_directory}/#{artifact}.zip") { true }

      run_recipe 'jdk'
    end

    it 'the installer is unzipped' do
      stub(main).not_if
      stub(main).action

      mock(main).windows_zipfile("#{download_directory}/#{artifact}").yields
      mock(main).source("#{download_directory}/#{artifact}.zip")

      run_recipe 'jdk'
    end

    it 'sets environment variables to the install directory' do
      stub(main).action
      stub(main).delim

      mock(main).env('JAVA_HOME').yields
      mock(main).env('JRE_HOME').yields
      mock(main).env('PATH').yields

      mock(main).value('c:\jdk\bin').times(3)

      run_recipe 'jdk'
    end
  end
end