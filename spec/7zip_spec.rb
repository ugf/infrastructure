require 'spec_helper'

main = self

describe '7zip' do

  zip7 = '7z465.exe'

  before :each do
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).powershell
    stub(main).env
  end

  it 'copies the installer' do

    stub(main).cookbook_file.yields

    mock(main).source zip7

    load '../cookbooks/7zip/recipes/default.rb'

  end

  it 'runs the executable' do

    stub(main).not_if
    stub(main).powershell.yields

    mock(main).source "cmd /c c:/installs/#{zip7} /S"

    load '../cookbooks/7zip/recipes/default.rb'

  end

  it 'sets the environment path' do

    stub(main).action
    stub(main).delim

    mock(main).env('PATH').yields
    mock(main).value "#{ENV['PROGRAMFILES(X86)']}\\7-zip"

    load '../cookbooks/7zip/recipes/default.rb'

  end
end