require_relative '../spec_helper'

describe 'share folder' do

  before { stub_all }
  after { run_recipe 'windows', 'share_temp_folder' }

  it 'should create the folder' do

    given.execute(/Create/).yields
    verify.command /mkdir.*temp/

  end

  it 'should share the folder' do

    given.execute(/Share/).yields
    verify.command /net share temp/

  end

end