#
# Cookbook Name:: automount
# Recipe:: default
#
# Copyright (C) 2014 Nephila Graphic
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
service_name = node['automount']['service']['name']

package node['automount']['package']['name'] do
  action :install
end

service "#{service_name}" do
  supports [:enable, :disable, :restart]
  action [:enable]
end

file '/etc/auto.direct' do
  owner 'root'
  group 'root'
  mode 0640
  action :create_if_missing
  notifies :restart, "service[#{service_name}]"
end

file '/etc/auto.master' do
  owner 'root'
  group 'root'
  mode 0644
  action :create_if_missing
  notifies :restart, "service[#{service_name}]"
end

# Ensure the following line exists in auto.master
# /- /etc/auto.direct --timeout=3600

ruby_block 'autofs.direct' do
  block do
    rc = Chef::Util::FileEdit.new('/etc/auto.master')
    rc.insert_line_if_no_match(/^\/\-/, "/- /etc/auto.direct --timeout=#{node['automount']['timeout']}")
    rc.search_file_replace_line(/^\/\-/, "/- /etc/auto.direct --timeout=#{node['automount']['timeout']}")
    rc.write_file
  end
  notifies :restart, "service[#{service_name}]"
end
