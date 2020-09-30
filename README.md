# Network programing samples for the Crystal language

This shard includes following sample codes.

- Gets following informations of the ethernet interfaces.

    - hardware address a.k.a. MAC address or phisical address
    - IPv4 address
    - IPv6 address

    _Tested on gnu(CentOS8)/musl(official alpine linux image) linux and  and BSD(Mac OS 10.14)._

- `ping` like command

    Sends ICMP ECHO request and receive its REPLY.

_NOTE: Included codes are not practical but only samples._

## Installation

1. Add the dependency to your `shard.yml`
```yaml
dependencies:
  net_sample:
    github: arcage/net_sample.cr
```
2. Run `shards install`

## Usage

```crystal
require "net_sample"

# get interface names
NetSample::NIC.ifnames
#=> ["lo0", "eth1"]

puts eth1 = NetSample::NIC["eth1"]
#=> <NIC: "eth1", inaddr: 192.0.2.100, in6addr: fe80::1234:abcd, hwaddr: aa:bb:cc:dd:ee:ff>

# ping like command(require root privirage)
NetSample::Ping.command("192.0.2.1")
#=> 
# PING 192.0.2.1: 56 data bytes
# 64 bytes from 192.0.2.1: icmp_seq=0 ttl=253 time=1.903 ms
# 64 bytes from 192.0.2.1: icmp_seq=1 ttl=253 time=1.466 ms
# 64 bytes from 192.0.2.1: icmp_seq=2 ttl=253 time=1.355 ms
# 64 bytes from 192.0.2.1: icmp_seq=3 ttl=253 time=2.115 ms
# 64 bytes from 192.0.2.1: icmp_seq=4 ttl=253 time=2.074 ms
# 
# --- 192.0.2.1 ping statistics ---
# 5 packets transmitted, 5 packets received, 0% packet loss
# round-trip min/avg/max/stddev = 1.355/1.783/2.115/0.346 ms
```

## Contributors

- [ʕ·ᴥ·ʔAKJ](https://github.com/arcage) - creator and maintainer
