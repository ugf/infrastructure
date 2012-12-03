rightscale_marker :begin

powershell 'Installing visual studio' do
  script = <<-EOF
    $install_dir = join-path ${ENV:\PROGRAMFILES(X86)} "Microsoft Visual Studio 11.0"
    if (test-path "c:\\VS2012\\log.txt")
    {
      Write-Output "VS2012 is in a reboot cycle, let it finish on it's own."

      do {
        write-host 'Waiting for visual studio...'
        start-sleep 5
      }
      while (( get-process | where-object {$_.name -eq 'vs_premium'} ).count -gt 0)

      write-host 'Visual Studio successfully installed'

      rename-item "c:\\VS2012\\log.txt" "c:\\VS2012\\log_complete.txt"

      exit 0
    }

    if (test-path $install_dir)
    {
       Write-Output "VS2012 already installed. Skipping installation."
       exit 0
    }

    & "c:\\VS2012\\vs_premium.exe" "/noweb" "/full" "/log" "c:\\VS2012\\log.txt" "/quiet" "/forcerestart"
  EOF
  source(script)
end

rightscale_marker :end