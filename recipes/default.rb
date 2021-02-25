#
# Cookbook Name:: gobgp
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

require 'yaml'

user = node['gobgp']['user']
group = node['gobgp']['group']
config_file = node['gobgp']['config_file']
binary = ::File.join(node['ark']['prefix_bin'], 'gobgpd')
cmd = "#{binary} -f #{config_file} -t yaml -p --sdnotify"
# TODO: This forces go DNS resolution instead of dynamic one, due to libc incompatibility.
# Remove this once https://github.com/osrg/gobgp/issues/2396 is fixed
gobgpenv = 'GODEBUG=netdns=go'

# Install the binaries
ark 'gobgp' do
  url              node['gobgp']['binary']['url']
  checksum         node['gobgp']['binary']['checksum']
  version          node['gobgp']['binary']['version']
  has_binaries     %w[gobgp gobgpd]
  strip_components 0
  notifies         :restart, 'systemd_service[gobgpd]', :delayed
end

# Create user/group
group node['gobgp']['group']

user user do
  gid group
  shell '/sbin/nologin'
  manage_home false
end

# Create the configuration file
file config_file do
  owner    user
  group    group
  mode     '0644'
  content  node['gobgp']['config'].to_hash.to_yaml
  notifies :reload, 'systemd_service[gobgpd]', :delayed
  verify   "#{gobgpenv} #{binary} -f %<path>s -t yaml -d"
end

# Create gobgpd sysconfig file
template node['gobgp']['environment_file'] do
  source 'gobgpd.sysconfig.erb'
  variables(
    options: node['gobgp']['options'],
  )
  notifies :restart, 'systemd_service[gobgpd]', :delayed
end

# Create the systemd service
systemd_service 'gobgpd' do
  unit do
    description   'GoBGP'
    documentation 'https://osrg.github.io/gobgp'
    wants         'network.target'
    after         %w[network.target syslog.target]
  end
  service do
    type                 'notify'
    user                 user
    group                group
    ambient_capabilities 'CAP_NET_BIND_SERVICE'
    exec_start_pre       "#{cmd} -d"
    exec_start           "#{cmd} $OPTIONS"
    exec_reload          '/bin/kill -HUP $MAINPID'
    environment          gobgpenv
    environment_file     node['gobgp']['environment_file']
  end
  install do
    wanted_by 'multi-user.target'
  end
  action %i[create enable start]
end

# Bash completion
package 'bash-completion'

uri_hash = ::Mash.new(
  "gobgp-completion.bash":         'da5d2e6a39f1e17c81e441b603b31a798edaaa9997015619125f6e2bd904fcd6',
  "gobgp-dynamic-completion.bash": 'a0c9e451af1b3041ecd202a813691d6ceff99283c12c4203abec6e1bbbb6f07b',
  "gobgp-static-completion.bash":  '1b963fb0254b68e796324bb6b7798bc9a391276033e07b0c06d10d15385e7028',
)
url = "https://raw.githubusercontent.com/osrg/gobgp/v#{node['gobgp']['binary']['version']}/tools/completion/"
dest = '/etc/bash_completion.d/'

uri_hash.each do |uri, checksum|
  remote_file uri do
    source url + uri
    path dest + uri
    checksum checksum
  end
end
