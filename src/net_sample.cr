require "socket"

module NetSample
  VERSION = "0.2.4"

  class Error < Exception; end
end

require "./net_sample/*"
