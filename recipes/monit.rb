#
# Cookbook Name:: automount
# Recipe:: monit
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

include_recipe 'monit'

ruby_block 'read_custom_mounts' do
  block do
    matcher = /^\s*(?<mount>[\/\w_-]+)\s+/
    node.default['automount']['monit']['mounts'] = ::File.readlines('/etc/auto.direct').select do |line|
      matcher =~ line
    end.map do |line|
      matcher.match(line)[:mount]
    end
  end
end

template "/etc/monit/conf.d/autofs.conf" do
  owner "root"
  group "root"
  mode 0644
  source 'monit.autofs.erb'
  cookbook 'automount'
  variables lazy {
    {
        :mounts => node['automount']['monit']['mounts']
    }
  }
  notifies :restart, resources(:service => "monit")
  action :create
end