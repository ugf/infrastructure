require 'spec_helper'

describe 'Gallio' do
  let(:ruby_scripts_dir) { '/rubyscripts' }
  let(:installs_directory) { '/installs' }
  let(:artifact) { 'gallio' }

  before :each do
    stub_all
    given.node {{platform: 'windows'}}
  end

  describe 'default' do
    after :each do
      run_recipe 'gallio'
    end

    it 'should include download_vendor_artifacts_prereqs recipe' do
      verify.include_recipe 'core::download_vendor_artifacts_prereqs'
    end

    it 'should raise error for ubuntu' do
      given.node {{platform: 'ubuntu'}}
      verify.raise 'Not implemented yet'
    end

    it 'should create download script' do
      given.node {{ruby_scripts_dir: ruby_scripts_dir}}
      verify.template "#{ruby_scripts_dir}/download_gallio.rb"
    end

    it 'should download gallio' do
      given.node {{ruby_scripts_dir: ruby_scripts_dir}}
      given.execute('Download gallio').yields
      verify.command "ruby #{ruby_scripts_dir}/download_gallio.rb"
    end

    it 'should unzip artifact' do
      given.node {{installs_directory: installs_directory}}
      given.windows_zipfile("#{installs_directory}/#{artifact}").yields
      verify.source "#{installs_directory}/#{artifact}.zip"
      verify.action :unzip
    end

    it 'should install gallio' do
      given.node {{installs_directory: installs_directory}}
      given.windows_package('Install gallio').yields
      verify.source "#{installs_directory}/#{artifact}/GallioBundle-3.4.14.0-Setup-x64.msi"
    end
  end
end