# Network programing samples for the Crystal language

This shard includes following the sample codes.

- Gets hardware addresses(MAC address / phisical address) of the network interfaces.

    Implemented for linux(tested on CentOS7) and BSD(tested on Mac OS 10.14).

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

# get HW address from given network interface name
mac_of_eth1 = NetSample::HWAddr.hwaddr_of("eth1")

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
