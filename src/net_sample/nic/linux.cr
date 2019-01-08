{% skip_file unless flag?(:linux) %}

lib LibC
  IF_NAMESIZE   =     16
  SIOCGIFHWADDR = 0x8927
  SIOCGIFCONF   = 0x8912
  MAX_IFS       =     32

  struct Ifmap
    mem_start : ULong
    mem_end : ULong
    base_addr : UShort
    irq : UChar
    dma : UChar
    port : UChar
  end

  union IfreqU
    ifr_addr : Sockaddr
    ifr_dstaddr : Sockaddr
    ifr_broadaddr : Sockaddr
    ifr_netmask : Sockaddr
    ifr_hwaddr : Sockaddr
    ifr_flags : Short
    ifr_ifindex : Int
    ifr_metric : Int
    ifr_mtu : Int
    ifr_map : Ifmap
    ifr_slave : Char[IF_NAMESIZE]
    ifr_newname : Char[IF_NAMESIZE]
    ifr_data : Char*
  end

  struct Ifreq
    ifr_name : Char[IF_NAMESIZE]
    ifr_req_u : IfreqU
  end

  alias IfconfReq = StaticArray(Ifreq, MAX_IFS)

  union IfconfU
    ifc_buf : Char*
    ifc_req : IfconfReq*
  end

  struct Ifconf
    ifc_len : Int
    ifc_u : IfconfU
  end

  fun ioctl(fd : Int, request : Int, value_result : Void*) : Int
end

class NetSample::HWAddr
  private def self.get_nic_info : Hash(String, self)
    nics = Hash(String, self).new { |h,k| h[k] = self.new(k)}
    get_hwaddr(nics)
    nics
  end

  private def self.get_hwaddr(nics : Hash(String, self)) : Hash(String, self)
    if_names = [] of String
    ifconf = LibC::Ifconf.new
    ifconf_req = LibC::IfconfReq.new { LibC::Ifreq.new }
    ifconf.ifc_len = sizeof(LibC::IfconfReq)
    ifconf.ifc_u.ifc_req = pointerof(ifconf_req)
    socket = LibC.socket(LibC::AF_INET, LibC::SOCK_DGRAM, 0)
    if LibC.ioctl(socket, LibC::SIOCGIFCONF, pointerof(ifconf).as(Void*)) < 0
      raise "Error: #{Errno.new(Errno.value)}\n"
    end
    ifconf_req.each do |ifreq|
      ifr_addr = ifreq.ifr_req_u.ifr_addr
      if ifr_addr.sa_family == LibC::AF_INET
        if_nlen = ifreq.ifr_name.to_slice.index { |b| b == 0u8 } || LibC::IF_NAMESIZE
        if_name = String.new(ifreq.ifr_name.to_slice[0, if_nlen])
        hwareq = LibC::Ifreq.new
        hwareq.ifr_req_u.ifr_addr.sa_family = LibC::AF_INET
        hwareq.ifr_name = ifreq.ifr_name
        if LibC.ioctl(socket, LibC::SIOCGIFHWADDR, pointerof(hwareq).as(Void*)) < 0
          raise "Error: #{Errno.new(Errno.value)}"
        end
        hwaddr = hwareq.ifr_req_u.ifr_addr.sa_data.to_slice[0, LibC::IFHWADDRLEN].clone
        nics[if_name].hwaddr = self.new(hwaddr)
      end
    end
  end
end
