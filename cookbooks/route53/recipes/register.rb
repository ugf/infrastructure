rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/register_with_route53.rb" do
  source 'scripts/route53.rb.erb'
  variables(
    :action => 'create',
    :domain => node[:route53][:domain],
    :prefix => node[:route53][:prefix],
    :route53_ip => node[:route53][:ip],
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key]
  )
end

if node[:route53][:ip] && node[:route53][:domain]
  execute 'Registering with Route53' do
    command "ruby #{node[:ruby_scripts_dir]}/register_with_route53.rb"
  end
  right_link_tag "route53:domain=#{node[:route53][:prefix]}.#{node[:route53][:domain]}"
end

rightscale_marker :end
