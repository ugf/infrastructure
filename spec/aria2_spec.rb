require 'spec_helper'

describe 'aria2' do

  aria2 = 'aria2.zip'
  dir = 'c:/installs'
  path = "#{dir}/#{aria2}"

  before :each do
    stub(Dir).mkdir
    stub_the.rightscale_marker
    stub_the.cookbook_file
    stub_the.windows_zipfile
  end

  it 'should copy the installer' do

    mock_the.cookbook_file(path).yields
    mock_the.source aria2

    run_recipe 'aria2'

  end

  it 'should unzip the file' do

    mock_the.windows_zipfile('c:/aria2').yields
    mock_the.source path
    mock_the.action :unzip
    stub_the.not_if

    run_recipe 'aria2'
  end
end