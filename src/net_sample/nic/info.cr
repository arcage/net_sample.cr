struct NetSample::NIC::Info
  enum Type
    InAddr
    In6Addr
    HWAddr
  end

  getter name
  getter type
  getter value

  def initialize(@name : String, @type : Type, @value : Bytes)
  end
end
