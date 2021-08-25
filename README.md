# gobgp

This cookbook downloads, installs and configures GoBGP.

## Cookbooks dependencies
* ark
* systemd

## Platforms
* CentOS

## Attributes
- `node['gobgp']['version']`- The version og GoBGP to download. Default `2.30.0`
- `node['gobgp']['checksum']`- Checksum of the archive of GoBGP.
- `node['gobgp']['user']` - GoBGP system user name. Default `gobgpd`
- `node['gobgp']['group']` - GoBGP system group name. Default `gobgpd`
- `node['gobgp']['config_file']` Path of the configuration file. Default `/etc/gobgpd.conf`
- `node['gobgp']['config']` A Hash of variables which is converted to yaml file. This yaml file is the configuration file for GoBGP.

## Examples

```ruby
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

default['policy_cyclop']['gobgp']['config']['neighbors'] |= [
  ::Mash.new(
    "config": {
      "neighbor-address": '192.0.2.42',
      "peer-as":          64_502,
    },
  )
]
```
