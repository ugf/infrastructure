require_relative '../spec_helper'

describe 'ruby' do

  before :each do
    stub_the.include_recipe
  end

  it 'should run the 3 recipes in ruby cookbook' do
    mock_the.include_recipe 'ruby::install'
    mock_the.include_recipe 'ruby::devkit'
    mock_the.include_recipe 'ruby::gems'

    run_recipe 'ruby'
  end
end