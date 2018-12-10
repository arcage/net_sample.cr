{% skip_file unless flag?(:bsd) || flag?(:darwin) %}

lib LibC
  AF_LINK       = 18
  SDL_DATA_SIZE = 32

  struct SockaddrDl
    sdl_len : UChar
    sdl_family : UChar
    sdl_index : UShort
    sdl_type : UChar
    sdl_nlen : UChar
    sdl_alen : UChar
    sdl_slen : UChar
    sdl_data : Char[SDL_DATA_SIZE]
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
end

class NetSample::HWAddr
  private def self.get_hwaddr : Hash(String, self)
    hwaddrs = {} of String => self
    ifa = LibC::Ifaddrs.new
    ifap = pointerof(ifa)
    LibC.getifaddrs(ifap)
    while ifap
      ifa = ifap.value
      if ifa.ifa_addr
        dl = ifa.ifa_addr.as(LibC::SockaddrDl*).value
        if dl.sdl_family == LibC::AF_LINK
          nlen = dl.sdl_nlen
          alen = dl.sdl_alen
          if alen == LibC::IFHWADDRLEN
            data = dl.sdl_data.to_slice.clone
            alen = nlen > LibC::SDL_DATA_SIZE - LibC::IFHWADDRLEN ? LibC::SDL_DATA_SIZE - nlen : LibC::IFHWADDRLEN
            if_name = String.new(data[0, nlen])
            hwaddr = data[nlen, alen]
            hwaddrs[if_name] = self.new(hwaddr)
          end
        end
      end
      ifap = ifa.ifa_next
    end
    hwaddrs
  end
end
