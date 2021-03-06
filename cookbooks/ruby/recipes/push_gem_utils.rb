rightscale_marker :begin

include_recipe 'core::download_product_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_gem_utils.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:ruby][:gem_utils_artifacts],
    :target_directory => node[:gem_utils_dir],
    :revision => node[:ruby][:gem_utils_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:ruby][:s3_gem_utils_repository],
    :s3_directory => 'Utils'
  )
end

execute 'Downloading artifacts' do
  command "ruby #{node[:ruby_scripts_dir]}/download_gem_utils.rb"
end

execute 'push gem utils' do
  command 'gem inabox us_utils*.gem -g http://localhost'
  cwd "#{node[:gem_utils_dir]}/#{node[:ruby][:gem_utils_artifacts]}"
end

rightscale_marker :end
