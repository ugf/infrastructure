require 'spec_helper'

describe 'Install winhttpcertcfg' do

  before :each do
    stub_all
    stub(File).exist? { true }
  end

  after :each do
    run_recipe 'windows', 'install_winhttpcertcfg'
  end

  it 'should copy the installer' do

    given.cookbook_file.yields
    verify.source 'winhttpcertcfg.msi'

  end

  it 'should run the installer' do

    given.execute(/Install/).yields
    verify.command /winhttpcertcfg.msi/
  end

end