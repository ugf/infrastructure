class Chef::Resource
  include DetectVagrant
end

class Chef::Recipe
  include DetectVagrant
end

emit_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

ruby_version = '1.9.2-p320'
install_dir = '/opt/ruby'
source_dir = '/tmp/src/ruby'

if node[:platform] == "ubuntu"
  if File.exists?(install_dir)
    log 'Ruby already installed'
  else

    template "#{node[:ruby_scripts_dir]}/download_ruby.rb" do
      local true
      source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
      variables(
        :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => 'ruby',
        :version => ruby_version,
        :artifacts => 'ruby',
        :target_directory => '/tmp/src'
      )
    end

    directory source_dir do
      recursive true
      action :delete
      only_if { vagrant_exists? }
    end

    directory source_dir do
      recursive true
      mode 00777
      action :create
      only_if { vagrant_exists? }
    end

    ruby_block 'Install fog' do
      block do
        ENV['RUBYGEMS_BINARY_PATH'] ||= 'gem'
        system("/opt/rightscale/sandbox/bin/gem install fog -v 1.1.1 --no-rdoc --no-ri")
      end
      not_if { vagrant_exists? }
    end

    bash 'Download ruby' do
      code <<-EOF
        /opt/rightscale/sandbox/bin/ruby -rubygems #{node[:ruby_scripts_dir]}/download_ruby.rb
        unzip -d #{source_dir} #{source_dir}.zip
      EOF
      not_if { vagrant_exists? }
    end

    bash 'Unzip ruby artifact' do
      code <<-EOF
      if [ ! -d #{source_dir} ]; then mkdir -p #{source_dir}; fi
      unzip -d #{source_dir} /vendor_artifacts/ruby/#{ruby_version}/ruby.zip
      EOF
      only_if { vagrant_exists? }
    end

    ruby_packages = ['libreadline-dev', 'libssl-dev', 'libyaml-dev', 'libffi-dev', 'libncurses-dev', 'libdb-dev' ,
      'libgdbm-dev', 'tk-dev']

    ruby_packages.each do |name|
      package name do
      end
    end

    file "#{source_dir}/configure" do
      mode 00777
    end

    file "#{source_dir}/tool/ifchange" do
      mode 00777
    end

    execute 'configure' do
      command "./configure --enable-shared --prefix=#{install_dir}/#{ruby_version}"
      cwd source_dir
    end

    make_commands = ['all', 'test', 'install']
    make_commands.each do |cmd|
      execute "make #{cmd}" do
        command "make #{cmd}"
        cwd source_dir
      end
    end

    link "#{install_dir}/active" do
      action :delete
      only_if "test -L #{install_dir}/active"
    end

    execute 'create sym link' do
      command "ln -fs #{ruby_version} active"
      cwd install_dir
    end

    executables = ['ruby', 'gem', 'rake', 'rspec', 'rdoc', 'ri', 'bundle', 'cucumber', 'rails']

    executables.each do |exe|
      file "/usr/bin/#{exe}" do
        action :delete
      end
    end

    executables.each do |exe|
      link "/usr/bin/#{exe}" do
        to "#{install_dir}/active/bin/#{exe}"
      end
    end
  end
else
  template "#{node[:ruby_scripts_dir]}/download_ruby.rb" do
    local true
    source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'ruby',
      :version => ruby_version,
      :artifacts => 'ruby_windows',
      :target_directory => '/installs'
    )
    not_if { File.exist?('/installs/ruby_windows.zip') }
  end

  powershell 'Install fog and download ruby' do
    script = <<'EOF'
    cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"
    cmd /c gem install fog -v 1.1.1 --no-rdoc --no-ri
    cmd /c ruby -rubygems c:\\rubyscripts\\download_ruby.rb
EOF
    source(script)
    not_if { File.exist?('/Ruby192') }
  end

  windows_zipfile '/installs/ruby_windows' do
    source '/installs/ruby_windows.zip'
    action :unzip
    not_if { File.exist?('/installs/ruby_windows') }
  end

  powershell 'Install ruby' do
    source('c:\\installs\\ruby_windows\\rubyinstaller-1.9.2-p0.exe /tasks=modpath /silent')
    not_if { File.exist?('/Ruby192') }
  end
end

emit_marker :end
