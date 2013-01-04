

rightscale_marker :begin


execute 'Adding certificate' do
  command 'certutil -f -p password -importpfx passiveSTS.pfx'
  cwd "#{node[:binaries_directory]}/certificate"
end


rightscale_marker :end