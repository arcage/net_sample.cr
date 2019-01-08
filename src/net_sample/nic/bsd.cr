{% skip_file unless flag?(:bsd) || flag?(:darwin) %}

lib LibC
  AF_LINK       = 18
  SDL_DATA_SIZE = 32
  INET_ADDRSTRLEN = 16
  INET6_ADDRSTRLEN = 46

  struct SockaddrDl
    sdl_len    : UChar
    sdl_family : SaFamilyT
    sdl_index  : UShort
    sdl_type   : UChar
    sdl_nlen   : UChar
    sdl_alen   : UChar
    sdl_slen   : UChar
    sdl_data   : Char[SDL_DATA_SIZE]
    {% if flag?(:darwin) %}
    sdl_rcf    : UShort
    sdl_route  : UShort[16]
    {% end %}
  end

  struct Ifaddrs
    ifa_next : Ifaddrs*
    ifa_name : Char*
    ifa_flags : UInt
    ifa_addr : Sockaddr*
    ifa_netmask : Sockaddr*
    ifa_dstaddr : Sockaddr*
    ifa_data : Void*
  end

  fun getifaddrs(ifaddr : Ifaddrs*) : Int
  fun inet_ntop(af : Int, src : Void*, dst : Char*, size : SocklenT) : Char*
end

class NetSample::NIC
  private def self.get_nic_info : Hash(String, self)
    nics = Hash(String, self).new { |h,k| h[k] = self.new(k)}
    ifa = LibC::Ifaddrs.new
    ifap = pointerof(ifa)
    LibC.getifaddrs(ifap)
    while ifap
      ifa = ifap.value
      if ifa_addr = ifa.ifa_addr
        if_name = String.new(ifa.ifa_name)
        case ifa_addr.value.sa_family
        when LibC::AF_INET
          ina = ifa_addr.as(LibC::SockaddrIn*).value
          dst = StaticArray(UInt8, LibC::INET_ADDRSTRLEN).new(0)
          addr = ina.sin_addr.s_addr
          LibC.inet_ntop(LibC::AF_INET, pointerof(addr).as(Void*), dst, LibC::INET_ADDRSTRLEN)
          nics[if_name].inaddr = String.new(dst.to_unsafe)
        when LibC::AF_INET6
          ina = ifa_addr.as(LibC::SockaddrIn6*).value
          dst = StaticArray(UInt8, LibC::INET6_ADDRSTRLEN).new(0)
          addr6 = ina.sin6_addr.__u6_addr.__u6_addr8
          LibC.inet_ntop(LibC::AF_INET6, addr6.to_unsafe.as(Void*), dst, LibC::INET6_ADDRSTRLEN)
          nics[if_name].in6addr = String.new(dst.to_unsafe)
        when LibC::AF_LINK
          dla = ifa_addr.as(LibC::SockaddrDl*).value
          if (alen = dla.sdl_alen) == LibC::IFHWADDRLEN
            nlen = dla.sdl_nlen
            data = dla.sdl_data.to_slice.clone
            alen = nlen > LibC::SDL_DATA_SIZE - LibC::IFHWADDRLEN ? LibC::SDL_DATA_SIZE - nlen : LibC::IFHWADDRLEN
            if_name = String.new(data[0, nlen])
            hwaddr = data[nlen, alen]
            nics[if_name].hwaddr = hwaddr
          end
        end
      end
      ifap = ifa.ifa_next
    end
    nics
  end
end
