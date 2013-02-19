rightscale_marker :begin

include_recipe 'core::download_product_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_binaries.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:newgen][:binaries_artifacts],
    :target_directory => node[:binaries_directory],
    :revision => node[:newgen][:binaries_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:core][:s3_repository],
    :s3_directory => 'Binaries'
  )
end

execute 'Build' do
  command 'gem build utils.gemspec'
end

execute 'Build' do
  command 'gem install utils-0.0.1.gem'
end

rightscale_marker :end
