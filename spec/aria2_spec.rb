require 'spec_helper'

main = self

describe 'aria2' do

  recipe = -> { load '../cookbooks/aria2/recipes/default.rb' }
  aria2 = 'aria2.zip'
  dir = 'c:/installs'
  path = "#{dir}/#{aria2}"

  before :each do
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).windows_zipfile
  end

  it 'should copy the installer' do

    mock(main).cookbook_file(path).yields
    mock(main).source aria2

    recipe.call

  end

  it 'should unzip the file' do

    mock(main).windows_zipfile('c:/aria2').yields
    mock(main).source path
    mock(main).action :unzip
    stub(main).not_if

    recipe.call
  end
end