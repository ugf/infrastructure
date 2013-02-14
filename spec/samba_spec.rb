require 'spec_helper'

describe 'samba' do

  before { stub_all }
  after { run_recipe 'samba' }

  it 'should be installed' do

    given.package('samba').yields
    verify.action :install

  end

end