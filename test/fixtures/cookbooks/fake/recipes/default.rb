include_recipe 'apt'

# Install samba server
include_recipe 'samba::server'

# Setup loopback samba share for testing
user 'testshare' do
  comment 'test user'
  shell '/bin/false'
end

samba_user 'testshare' do
  password 'secretpass'
  action [:create, :enable]
end

include_recipe 'samba::client'

# Lets' mount!
include_recipe 'automount'

service 'autofs' do
  supports [:enable, :disable, :restart]
  action :restart
end

automount '/mnt/testshare1' do
  fstype 'cifs'
  device '//127.0.0.1/TestShare'
  options 'noperm,noexec,username=testshare,password=secretpass'
  action :enable
end

automount '/mnt/testshare2' do
  fstype 'cifs'
  device '//127.0.0.1/TestShare'
  options 'noperm,noexec,username=testshare,password=secretpass'
  action :enable
  notifies :restart, 'service[autofs]'
end

automount '/mnt/testshare1' do
  action :disable
end
