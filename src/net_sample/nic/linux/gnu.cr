{% skip_file unless flag?(:gnu) %}

class NetSample::NIC
  private def self.read_ifa(ifa) : NetSample::NIC::Info?
    name = nil
    type = nil
    value = nil
    nic = nil
    if ifa_addr = ifa.ifa_addr
      name = String.new(ifa.ifa_name)
      case ifa_addr.value.sa_family
      when LibC::AF_INET
        ina = ifa_addr.as(LibC::SockaddrIn*).value
        dst = StaticArray(UInt8, LibC::INET_ADDRSTRLEN).new(0)
        addr = ina.sin_addr.s_addr
        LibC.inet_ntop(LibC::AF_INET, pointerof(addr).as(Void*), dst, LibC::INET_ADDRSTRLEN)
        type = NetSample::NIC::Info::Type::InAddr
        value = dst.to_slice.clone
      when LibC::AF_INET6
        ina = ifa_addr.as(LibC::SockaddrIn6*).value
        dst = StaticArray(UInt8, LibC::INET6_ADDRSTRLEN).new(0)
        addr6 = ina.sin6_addr.__in6_u.__u6_addr8
        LibC.inet_ntop(LibC::AF_INET6, addr6.to_unsafe.as(Void*), dst, LibC::INET6_ADDRSTRLEN)
        type = NetSample::NIC::Info::Type::In6Addr
        value = dst.to_slice.clone
      when LibC::AF_PACKET
        lla = ifa_addr.as(LibC::SockaddrLl*).value
        data = lla.sll_addr.to_slice.clone
        hwaddr = data[0, LibC::IFHWADDRLEN]
        type = NetSample::NIC::Info::Type::HWAddr
        value = hwaddr
      end
    end
    nic = NetSample::NIC::Info.new(name, type, value) if name && type && value
    nic
  end


end
