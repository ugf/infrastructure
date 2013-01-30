require 'spec_helper'
main = self

describe 'core' do

  recipe = -> (name) { load "../cookbooks/core/recipes/#{name}.rb" }

  it 'should download product artifacts prereqs' do

    recipe.call download_product_artifacts_prereqs

  end

end