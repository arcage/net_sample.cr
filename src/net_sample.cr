require "socket"

module NetSample
  VERSION = "0.2.3"
  class Error < Exception; end
end

require "./net_sample/*"
