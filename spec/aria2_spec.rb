require 'spec_helper'
main = self


describe 'aria2' do

  aria2 = 'aria2.zip'
  dir = 'c:/installs'
  path = "#{dir}/#{aria2}"
  recipe = -> { load '../cookbooks/aria2/recipes/default.rb' }

  before :each do
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).windows_zipfile
  end

  it 'copies the installer' do

    mock(main).cookbook_file(path).yields
    mock(main).source aria2

    recipe.call

  end

end