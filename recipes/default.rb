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
cmd = "#{binary} -f #{config_file} -t yaml -p"

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
end

# Create the configuration file
file config_file do
  owner    user
  group    group
  mode     '0644'
  content  node['gobgp']['config'].to_hash.to_yaml
  notifies :reload, 'systemd_service[gobgpd]', :delayed
  verify   "#{binary} -f %<path>s -t yaml -d"
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
    type                 'simple'
    user                 user
    group                group
    ambient_capabilities 'CAP_NET_BIND_SERVICE'
    exec_start_pre       "#{cmd} -d"
    exec_start           cmd
    exec_reload          '/bin/kill -HUP $MAINPID'
  end
  install do
    wanted_by 'multi-user.target'
  end
  action %i[create enable start]
end
