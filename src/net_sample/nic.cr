require "./nic/*"

lib LibC
  IFHWADDRLEN      =  6
  INET_ADDRSTRLEN  = 16
  INET6_ADDRSTRLEN = 46

  fun getifaddrs(ifaddr : Ifaddrs**) : Int
  fun freeifaddrs(ifaddr : Ifaddrs*) : Void
  fun inet_ntop(af : Int, src : Void*, dst : Char*, size : SocklenT) : Char*
end

class NetSample::NIC
  @@nics : Hash(String, self)?

  def self.nics
    @@nics ||= get_nic_info
  end

  def self.ifnames
    self.nics.keys
  end

  def self.inaddr_of(if_name)
    self.nics[if_name]?.try &.inaddr
  end

  def self.in6addr_of(if_name)
    self.nics[if_name]?.try &.in6addr
  end

  def self.hwaddr_of(if_name)
    self.nics[if_name]?.try &.hwaddr
  end

  def self.[](if_name)
    self.nics[if_name]
  end

  def self.[]?(if_name)
    self.nics[if_name]?
  end

  def self.each(&block)
    self.nics.values.each do |nic|
      yield nic
    end
  end

  private def self.get_nic_info : Hash(String, self)
    nics = Hash(String, self).new { |h, k| h[k] = self.new(k) }
    if LibC.getifaddrs(out ifaddrs) == -1
      raise Error.new("errno #{Errno.value} on getifaddr()")
    end
    ifap = ifaddrs.as(LibC::Ifaddrs*)
    while ifap
      ifa = ifap.value
      if info = read_ifa(ifa)
        nic = nics[info.name]
        case info.type
        when NetSample::NIC::Info::Type::InAddr
          nic.inaddr = String.new(info.value)
        when NetSample::NIC::Info::Type::In6Addr
          nic.in6addr = String.new(info.value)
        when NetSample::NIC::Info::Type::HWAddr
          nic.hwaddr = info.value
        end
      end
      ifap = ifa.ifa_next
    end
    LibC.freeifaddrs(ifaddrs)
    nics
  end

  property inaddr : String?
  property in6addr : String?
  setter hwaddr : Bytes?

  def initialize(@name : String)
  end

  def to_s(io : IO)
    io << "<NIC: " << @name.inspect
    io << ", " << "inaddr: " << @inaddr if @inaddr
    io << ", " << "in6addr: " << @in6addr if @in6addr
    if @hwaddr
      io << ", " << "hwaddr: "
      internal_hwaddr(io)
    end
    io << ">"
  end

  private def internal_hwaddr(io : IO)
    i = 0
    if bytes = @hwaddr
      byte_size = bytes.size
      loop do
        io << ("%02x" % bytes[i])
        i += 1
        if i == byte_size
          break
        end
        io << ':'
      end
      io << ":??" unless byte_size == LibC::IFHWADDRLEN
    end
  end

  def hwaddr
    if bytes = @hwaddr
      String.build do |io|
        hwaddr(io)
      end
    else
      nil
    end
  end
end
