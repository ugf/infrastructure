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

    mock(main).source zip7

    def main.cookbook_file(name)
      yield
    end

    load '../cookbooks/7zip/recipes/default.rb'

  end

  it 'runs the executable' do

    stub(main).not_if

    mock(main).source "cmd /c c:/installs/#{zip7} /S"

    load '../cookbooks/7zip/recipes/default.rb'

  end


end