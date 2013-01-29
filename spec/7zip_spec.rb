require 'spec_helper'
main = self

describe '7zip' do

  recipe = -> { load '../cookbooks/7zip/recipes/default.rb' }
  zip7 = '7z465.exe'
  dir = 'c:/installs'
  path = "#{dir}/#{zip7}"

  before :each do
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).powershell
    stub(main).env
  end

  it 'copies the installer' do

    mock(main).cookbook_file(path).yields
    mock(main).source zip7

    recipe.call

  end

  it 'runs the executable' do

    stub(main).powershell.yields

    mock(main).source "cmd /c #{path} /S"
    stub(main).not_if

    recipe.call

  end

  it 'sets the environment path' do

    mock(main).env('PATH').yields

    stub(main).action
    stub(main).delim
    mock(main).value "#{ENV['PROGRAMFILES(X86)']}\\7-zip"

    recipe.call

  end
end