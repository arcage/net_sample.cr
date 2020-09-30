{% skip_file unless flag?(:linux) %}

lib LibC
  AF_PACKET = 17

  struct SockaddrLl
    sll_family : UShort
    sll_protocol : UInt16
    sll_ifinex : Int
    sll_hatype : UShort
    sll_pkttype : UChar
    sll_halen : UChar
    sll_addr : StaticArray(UChar, 8)
  end

  union IfaIfu
    ifu_broadaddr : Sockaddr*
    ifu_dstaddr : Sockaddr*
  end

  struct Ifaddrs
    ifa_next : Ifaddrs*
    ifa_name : Char*
    ifa_flags : UInt
    ifa_addr : Sockaddr*
    ifa_netmask : Sockaddr*
    ifa_ifu : IfaIfu
    ifa_data : Void*
  end
end

require "./linux/*"
