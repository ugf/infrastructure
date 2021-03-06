rightscale_marker :begin

class Chef::Resource
  include ConfigFiles
end

powershell 'Copying ui_tests' do
  parameters({
    'source' => "c:#{node[:binaries_directory].gsub('/', '\\')}",
    'target' => "c:#{node[:ui_tests_directory].gsub('/', '\\')}"
  })
  script = <<-EOF

    if (test-path $env:target) { remove-item $env:target -recurse }
    new-item $env:target -type directory -force

    copy-item "$env:source\\ui_tests\\*" "$env:target" -recurse -force
    copy-item "$env:source\\common_tests\\TabularData" "$env:target" -recurse -force

  EOF
  source(script)
end

ruby_block 'Updating config files' do
  block do
    update_ui_settings
    update_database_settings node[:ui_tests_directory]
  end
end

execute 'Run Gallio Smoke Tests' do
  command "\"c:\\Program Files\\Gallio\\bin\\Gallio.Echo.exe\" /rd:C:\\temp\\SmokeTests /rt:Html /rnf:index /filter:CategoryName:Smoke \"c:#{node[:ui_tests_directory].gsub('/', '\\')}\\bin\\UltimateSoftware.Echo.Automation.NewGen.UIAutomationTests.dll\""
  cwd node[:ui_tests_directory]
end

rightscale_marker :end
