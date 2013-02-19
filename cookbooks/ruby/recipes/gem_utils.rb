rightscale_marker :begin

include_recipe 'core::download_product_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_gem_utils.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:gem_utils][:gem_utils_artifacts],
    :target_directory => node[:infrastructure_directory],
    :revision => node[:gem_utils][:gem_utils_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:deployment_services][:s3_api_repository],
    :s3_directory => 'Utils'
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/download_gem_utils.rb
    EOF
  end
else
  powershell "Downloading artifacts" do
    source("ruby #{node[:ruby_scripts_dir]}/download_gem_utils.rb")
  end
end

execute 'Build utils' do
  command 'gem build utils.gemspec'
  cwd "#{node[:infrastructure_directory]}/#{node[:gem_utils][:gem_utils_artifacts]}"
end

execute 'Install utils' do
  command 'gem install utils-0.0.1.gem'
  cwd "#{node[:infrastructure_directory]}/#{node[:gem_utils][:gem_utils_artifacts]}"
end

rightscale_marker :end
