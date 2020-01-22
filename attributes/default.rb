default['gobgp']['binary']['version'] = '2.12.0'
gobgp_version = default['gobgp']['binary']['version']
default['gobgp']['binary']['url'] = "https://github.com/osrg/gobgp/releases/download/v#{gobgp_version}/gobgp_#{gobgp_version}_linux_amd64.tar.gz"
default['gobgp']['binary']['checksum'] = 'e4a3744e0ea6dec5e2ee2338bc6f1fc5cfd321605144c83ed2ad2f6734646996'

default['gobgp']['user'] = 'gobgpd'
default['gobgp']['group'] = 'gobgpd'
default['gobgp']['config_file'] = '/etc/gobgpd.conf'
default['gobgp']['environment_file'] = '/etc/sysconfig/gobgpd'

default['gobgp']['options'] = '--api-hosts=localhost:50051'
default['gobgp']['config'] = ::Mash.new(
  "global":             {
    "config": {
      "as":        64_501,
      "router-id": node['ipaddress'],
      "port":      1790,
    },
  },
  "neighbors":          [],
  "defined-sets":       {
    "prefix-sets": [],
  },
  "policy-definitions": [],
)
