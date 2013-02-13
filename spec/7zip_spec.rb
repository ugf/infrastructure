require 'spec_helper'

describe '7zip' do

  zip7 = '7z465.exe'
  dir = 'c:/installs'
  path = "#{dir}/#{zip7}"

  before :each do
    stub_all
    stub(Dir).mkdir
  end

  after :each do
    run_recipe '7zip'
  end

  it 'copies the installer' do

    given.cookbook_file(path).yields
    verify.source zip7

  end

  it 'runs the executable' do

    given.powershell.yields
    verify.source /cmd.*#{path}/

  end

  it 'sets the environment path' do

    given.env('PATH').yields
    verify.value /7-zip/

  end
end