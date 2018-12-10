lib LibC
  IFHWADDRLEN = 6
end

class NetSample::HWAddr
  @@hwaddrs : Hash(String, self)?

  def self.hwaddrs
    @@hwaddrs ||= get_hwaddr
  end

  def self.hwaddr_of(if_name : String) : self
    hwaddr_of?(if_name) || raise "#{if_name} not exist."
  end

  def self.hwaddr_of?(if_name : String) : self | Nil
    hwaddrs[if_name]?
  end

  def self.if_names : Array(String)
    hwaddrs.keys
  end

  def initialize(@bytes : Bytes)
  end

  def byte_size
    @bytes.size
  end

  def to_bytes
    @bytes
  end

  def to_s(io)
    i = 0
    loop do
      io << ("%02x" % @bytes[i])
      i += 1
      if i == byte_size
        break
      end
      io << ':'
    end
    io << ":??" unless byte_size == LibC::IFHWADDRLEN
  end
end

require "./hwaddr/*"
