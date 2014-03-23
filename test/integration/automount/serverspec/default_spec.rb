require 'serverspec'
require 'spec_helper'


include Serverspec::Helper::Exec


describe service('autofs') do
  it { should be_enabled }
  it { should be_running }
end


%w{/etc/auto.master /etc/auto.direct}.each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should_not be_writable.by('others') }
    it { should_not be_executable.by('others') }
  end
end

describe file('/etc/auto.direct') do
  # sensitive file possible passwords
  it { should_not be_readable.by('others') }
end

describe file('/etc/auto.master') do
  it { should contain '/- /etc/auto.direct --timeout=' }
end

describe file('/mnt/testshare1') do
  it { should_not be_file }
  it { should_not be_directory }
end

# Test mounts
%w{/mnt/testshare2}.each do |mount|

  describe command("stat #{mount}") do
    it { should return_exit_status 0 }
  end

  describe file(mount) do
    it { should be_directory }
    it { should be_mounted }
  end

end
