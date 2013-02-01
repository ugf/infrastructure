How to setup the repo
---------------------

`cd c:\`

`mkdir all_cookbooks`

`cd all_cookbooks`

`git clone git://github.com/ugf/infrastructure.git -b esx`


When we commit in infrastructure, to pull do
--------------------------------------------

`cd c:\all_cookbooks\infrastructure`

`git pull`


To run chef-solo
----------------

`chef-solo -c c:\all_cookbooks\infrastructure\chef-solo\solo.rb`


See also
--------
powershell cookbook: http://community.opscode.com/cookbooks/powershell


