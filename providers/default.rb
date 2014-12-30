#
# Cookbook Name:: automount
# Provider:: automount
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

action :disable do
  new_resource.updated_by_last_action(disable_direct)
end

action :enable do
  new_resource.updated_by_last_action(enable_direct)
end

private

def mountline
  # generate the automount line
  options = [
    "-fstype=#{new_resource.fstype}", new_resource.options
  ].flatten.join ','

  case new_resource.device_type
  when :device
    target = ":#{new_resource.device}"
  when :uuid
    target = ":UUID=#{new_resource.device}"
  when :label
    target = ":LABEL=#{new_resource.device}"
  end

  line = "#{new_resource.mount_point} #{options} #{target}"
  line
end

def mount_status?
  # Check to see if there is a entry in /etc/auto.direct. Last entry for a volume wins.
  enabled = false
  ::File.foreach('/etc/auto.direct') do |line|
    case line
    when /^[#\s]/
      next
    when /^\s*#{Regexp.escape(mountline)}\s*/
      return :enabled
    when /^\s*#{Regexp.escape(new_resource.mount_point)}\s+/
      Chef::Log.debug("Found conflicting mount point #{@new_resource.mount_point} in /etc/auto.direct")
      return :conflict
    end
  end

  if enabled
    return :enabled
  else
    return :missing
  end
end

# Returns true if changed, otherwise false.
def enable_direct
  case mount_status?
  when :enabled
    Chef::Log.debug("#{new_resource} is already enabled - nothing to do")
  when :missing, :conflict
    if mount_status? == :conflict
      Chef::Log.error("#{@new_resource} is conflicting with existing mount at #{@new_resource.mount_point}")
      disable_direct
    end

    ::File.open('/etc/auto.direct', 'a') do |fstab|
      fstab.puts(mountline)
      Chef::Log.debug("#{@new_resource} is enabled at #{@new_resource.mount_point}")
    end

    return true
  else
    return false
  end
end

# Returns true if changed, otherwise false
def disable_direct
  case mount_status?
  when :enabled, :conflict
    contents = []

    found = false
    ::File.readlines('/etc/auto.direct').reverse_each do |line|
      if !found && line =~ /^\s*#{Regexp.escape(new_resource.mount_point)}\s+/
        found = true
        Chef::Log.debug("#{@new_resource} is removed from fstab")
        next
      else
        contents << line
      end
    end

    ::File.open('/etc/auto.direct', 'w') do |fstab|
      contents.reverse_each { |line| fstab.puts line }
    end

    return true
  else
    Chef::Log.debug("#{@new_resource} is not enabled - nothing to do")
    return false
  end
end
