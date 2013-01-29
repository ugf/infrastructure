require 'spec_helper'

main = self

def powershell(name)
  yield
end

describe '7zip' do

  it 'runs the executable' do

    stub(main).not_if
    stub(main).rightscale_marker
    stub(main).cookbook_file
    stub(main).env

    mock(main).source "cmd /c c:/installs/7z465.exe /S"

    require_relative '../cookbooks/7zip/recipes/default'

  end

end