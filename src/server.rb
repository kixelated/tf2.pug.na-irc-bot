require 'steam-condenser'
require_relative 'constants'

class Server < SourceServer
  attr_reader :ip, :port, :name, :password
  
  def initialize(details = { name: "Localhost", ip: "127.0.0.1", port: 27015, password: "" })
    @name, @ip, @port, @password = *details.values
    super ip, port
  end
  
  def timeleft
    rcon_exec("timeleft") =~ /map:  (\S+?),/
    return $1.to_s
  end
  
  def to_s
    "connect #{ ip }:#{ port }; password #{ password }"
  end
end
