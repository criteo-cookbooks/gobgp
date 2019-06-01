default['gobgp']['binary']['version'] = '2.5.0'
gobgp_version = default['gobgp']['binary']['version']
default['gobgp']['binary']['url'] = "https://github.com/osrg/gobgp/releases/download/v#{gobgp_version}/gobgp_#{gobgp_version}_linux_amd64.tar.gz"
default['gobgp']['binary']['checksum'] = '912b28827966c175cf0adea1f8085df40a855638a1501af7eaadac0f823fefbf'

default['gobgp']['user'] = 'gobgpd'
default['gobgp']['group'] = 'gobgpd'
default['gobgp']['config_file'] = '/etc/gobgpd.conf'

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
