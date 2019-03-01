gobgp_version = '2.2.0'
default['gobgp']['binary']['version'] = gobgp_version
default['gobgp']['binary']['url'] = "https://github.com/osrg/gobgp/releases/download/v#{gobgp_version}/gobgp_#{gobgp_version}_linux_amd64.tar.gz"
default['gobgp']['binary']['checksum'] = '80009470228c376c28df87bd96e6f24da34851fce1f8ec434915423eb92694d0'

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
