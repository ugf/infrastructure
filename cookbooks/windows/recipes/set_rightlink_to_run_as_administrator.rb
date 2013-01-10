rightscale_marker :begin

powershell 'Setting RightLink login account' do
  parameters({ 'password' => node[:windows][:administrator_password] })
  script = <<-EOF
    sc config RightLink obj= administrator password= $env:password
    Restart-Service RightLink
  EOF
  source(script)
end

rightscale_marker :end