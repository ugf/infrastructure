require 'spec_helper'

describe '7zip' do

  zip7 = '7z465.exe'
  dir = 'c:/installs'
  path = "#{dir}/#{zip7}"

  before :each do
    stub(Dir).mkdir
    stub_the.rightscale_marker
    stub_the.cookbook_file
    stub_the.powershell
    stub_the.env
  end

  it 'copies the installer' do

    mock_the.cookbook_file(path).yields
    mock_the.source zip7

    run_recipe '7zip'

  end

  it 'runs the executable' do

    stub_the.powershell.yields

    mock_the.source "cmd /c #{path} /S"
    stub_the.not_if

    run_recipe '7zip'

  end

  it 'sets the environment path' do

    mock_the.env('PATH').yields

    stub_the.action
    stub_the.delim
    mock_the.value "#{ENV['PROGRAMFILES(X86)']}\\7-zip"

    run_recipe '7zip'

  end
end