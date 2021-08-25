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
gobgp_version = node['gobgp']['version'] || '2.30.0'
checksum = node['gobgp']['checksum'] || 'a83e9df4150d78d62d41e6bf218b82d16d0f716843e7e0b70fe443ed3cd991fa'

# Install the binaries
ark 'gobgp' do
  url              "https://github.com/osrg/gobgp/releases/download/v#{gobgp_version}/gobgp_#{gobgp_version}_linux_amd64.tar.gz"
  checksum         checksum
  version          gobgp_version
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
  verify   "#{binary} -f %<path>s -t yaml -d"
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
  "gobgp-completion.bash":         'c42a78ab910a2303362bb8665d36979af19076b861ebf78a17a0152d7ff16452',
  "gobgp-dynamic-completion.bash": '7f939dde6d8c4f2fe40cb358a25f69131df99caf6beac735ffe90120dc87fdb6',
  "gobgp-static-completion.bash":  '36e4d481b3e5a4a55d5de76cb3781390d505d8d3490d6306acf6acc956a79cb5',
)
url = "https://raw.githubusercontent.com/osrg/gobgp/v#{gobgp_version}/tools/completion/"
dest = '/etc/bash_completion.d/'

uri_hash.each do |uri, cs|
  remote_file uri do
    source url + uri
    path dest + uri
    checksum cs
  end
end
