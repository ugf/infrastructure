How to setup the repos in the machine
==============

cd c:\
mkdir all_cookbooks
cd all_cookbooks
git clone git://github.com/ugf/infrastructure.git -b esx
mkdir powershell\cookbooks
cd powershell\cookbooks
git clone git://github.com/opscode-cookbooks/powershell.git

everytime we commit in infrastructure, to pull do

cd c:\all_cookbooks\infrastructure
git pull

to run chef-solo
chef-solo -c c:\all_cookbooks\infrastructure\chef-solo\solo.rb


