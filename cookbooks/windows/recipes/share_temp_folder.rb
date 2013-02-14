rightscale_marker :begin

DIR = 'c:\temp'

#def missing?(cmd, txt)
#  `#{cmd} | find "#{txt}"`.empty?
#end

execute 'Create temp folder' do
  command "mkdir #{DIR}"
  not_if { File.exist? DIR }
end

execute 'Share temp folder' do
  command "net share temp=#{DIR} /GRANT:Everyone,READ"
  only_if { `net share temp | find "temp"`.empty? }
end

rightscale_marker :end