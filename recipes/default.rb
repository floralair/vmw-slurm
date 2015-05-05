#
# Cookbook Name:: vmw-slurm
# Recipe:: default
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
include_recipe "hadoop_common::pre_run"
include_recipe "hadoop_common::mount_disks"
include_recipe "hadoop_cluster::update_attributes"

    workers = all_providers_fqdn_for_role("slurm_worker")
    workers_fqdn = workers.join(",")
    workers_shortname = workers_fqdn.gsub('.asurite.ad.asu.edu','')
    master = all_providers_fqdn_for_role("slurm_master").last

user "slurmadmin" do
	supports :manage_home => true
	comment "SLURM Admin"
	uid 1234
	gid "users"
	home "/home/slurmadmin"
	shell "/bin/bash"
	password "$1$KiyeRecV$djdasp3PwYXCbP8k0ihjs1"
end

directory "/slurm" do
	owner "slurmadmin"
	group "users"
	mode 00755
	action :create
end

execute "yum-update" do
	cwd "/slurm"
	command "yum update -y"
end

yum_package "rpm-build" do
	action :install
end

yum_package "bzip2-devel" do
	action :install
end

yum_package "zlib-devel" do
	action :install
end

yum_package "openssl-devel" do
	action :install
end

yum_package "gcc" do
	action :install
end

yum_package "readline-devel" do
	action :install
end

yum_package "pam-devel" do
	action :install
end

yum_package "perl-CPAN" do
	action :install
end

yum_package "perl-DBI" do
	action :install
end

cookbook_file "/slurm/munge-0.5.11.tar.bz2" do
	source "munge-0.5.11.tar.bz2"
	mode 00711
	owner "slurmadmin"
	group "users"
end

execute "rpmbuild-munge" do
	cwd "/slurm"
	command "rpmbuild -tb --clean munge-0.5.11.tar.bz2"
end

execute "rpm-munge" do
	cwd "/root/rpmbuild/RPMS/x86_64"
	command "rpm -ivh munge*.rpm"
end

directory "/etc/munge" do
	owner "slurmadmin"
	group "users"
	mode 00700
	action :create
end

directory "/var/lib/munge" do
	owner "slurmadmin"
	group "users"
	mode 00711
	action :create
end

directory "/var/log/munge" do
	owner "slurmadmin"
	group "users"
	mode 00700
	action :create
end

directory "/var/run/munge" do
	owner "slurmadmin"
	group "users"
	mode 00755
	action :create
end

execute "build-munge-key" do
	cwd "/slurm"
	command "dd if=/dev/urandom bs=1 count=1024 >/etc/munge/munge.key"
end

execute "sha1sum-munge-key" do
	cwd "/slurm"
	command "echo -n 'foo' | sha1sum | cut -d' ' -f1 >/etc/munge/munge.key"
end

execute "chown-munge-key" do
	cwd "slurm"
	command "chown slurmadmin /etc/munge/munge.key"
end

execute "chmod-munge-key" do
	cwd "/slurm"
	command "chmod 0400 /etc/munge/munge.key"
end

cookbook_file "/etc/sysconfig/munge" do
	source "munge_options"
	mode 00611
	owner "root"
	group "root"
end

service "munge" do
	action [ :enable, :start ]
end

directory "/slurm/slurm-14.11.3" do
	owner "slurmadmin"
	group "users"
	mode 00755
	action :create
end

cookbook_file "/slurm/slurm-14.11.3.tar.bz2" do
	source "slurm-14.11.3.tar.bz2"
	mode 00711
	owner "slurmadmin"
	group "users"
end

#execute "untar-slurm" do
#	cwd "/slurm"
#	command "tar --bzip -x -f slurm*tar.bz2"
#end

#execute "configure-slurm" do
#	cwd "/slurm/slurm-14.11.3"
#	command "./configure"
#end

#execute "make-slurm" do
#	cwd "/slurm/slurm-14.11.3"
#	command "./make"
#end

#execute "make-install-slurm" do
#	cwd "/slurm/slurm-14.11.3"
#	command "./make install"
#end

execute "build-slurm-rpms" do
	cwd "/slurm"
	command "rpmbuild -ta slurm-14.11.3.tar.bz2"
end

execute "install-slurm-rpms" do
	cwd "/root/rpmbuild/RPMS/x86_64"
	command "rpm -ivh slurm*.rpm"
end

#cookbook_file "/etc/slurm/slurm.conf" do
#	source "slurm.conf"
#	mode 00755
#	owner "slurmadmin"
#	group "users"
#end

template '/etc/slurm/slurm.conf' do
  source 'slurm.conf.erb'
  variables(
	:master => master,
	:workers => workers_shortname
  )
  action :create
end

directory "/var/spool/slurmd" do
	owner "slurmadmin"
	group "users"
	mode 00755
	action :create
end

directory "/root/.ssh/" do
	owner "root"
	group "root"
	mode 00700
	action :create
end

directory "/home/slurmadmin/.ssh/" do
	owner "slurmadmin"
	group "users"
	mode 00700
	action :create
end

cookbook_file "/root/.ssh/authorized_keys" do
	source "authorized_keys"
	mode 00700
	owner "root"
	group "root"
end
cookbook_file "/home/slurmadmin/.ssh/authorized_keys" do
	source "authorized_keys"
	mode 00700
	owner "slurmadmin"
	group "users"
end

cookbook_file "/root/.ssh/id_rsa" do
	source "id_rsa.root"
	mode 00600
	owner "root"
	group "root"
end

cookbook_file "/home/slurmadmin/.ssh/id_rsa" do
	source "id_rsa.slurmadmin"
	mode 00600
	owner "slurmadmin"
	group "users"
end

cookbook_file "/root/.ssh/id_rsa.pub" do
	source "id_rsa.pub.root"
	mode 00644
	owner "root"
	group "root"
end

cookbook_file "/home/slurmadmin/.ssh/id_rsa.pub" do
	source "id_rsa.pub.slurmadmin"
	mode 00644
	owner "slurmadmin"
	group "users"
end

service "slurm" do
	action [ :enable, :start ]
end

