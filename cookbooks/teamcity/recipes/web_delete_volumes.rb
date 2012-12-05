rightscale_marker :begin

powershell('Delete volumes') do
  parameters(
    {
      'AWS_ACCESS_KEY_ID' => node[:core][:aws_access_key_id],
      'AWS_SECRET_ACCESS_KEY' => node[:core][:aws_secret_access_key],
    }
  )
  script = <<-EOF
    $rsLibDstDirPath = "$env:rs_sandbox_home\\RightScript\\lib"
    . "$rsLibDstDirPath\\ebs\\EbsDeleteVolume.ps1"
    . "$rsLibDstDirPath\\rs\\RsApiCallWithRetry.ps1"

    EbsDeleteVolume 'D'
    EbsDeleteVolume 'E'
  EOF
  source(script)
end

rightscale_marker :end