#
# Cookbook Name:: gengine
# Recipe:: master
#
# Copyright 2015, Andrew Nelson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#execute "disable-ssh-keycheck-root" do
#	command "ssh-keyscan -H gridslave1 >> /root/.ssh/known_hosts"
#end

=begin
execute "disable-ssh-keycheck-ugeadmin" do
	user "ugeadmin"
	command "ssh-keyscan -H slave1.vpod.local >> /home/ugeadmin/.ssh/known_hosts"
end



execute "search-and-add-key" do
	command "ssh-keyscan -t rsa,dsa HOST 2>&1 | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_hosts cat ~/.ssh/tmp_hosts >> ~/.ssh/known_hosts"
end
=end


execute "clear iptables" do
	cwd "/slurm"
	command "iptables -F"
end
