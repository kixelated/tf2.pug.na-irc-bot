class Server
  attr_accessor :ip, :port, :pswd, :rcon
  
  def initialize ip, port, pswd, rcon
    @ip = ip
    @port = port
    @pswd = pswd
    @rcon = rcon
    
    @connected = false
  end
  
  #establish connection to server and auth
  def connect 
    @conn = RCon::Query::Source.new(@ip, @port)
    @connected = @conn.auth rcon
  end
  
  #execute any command passed
  def command cmd
    connect unless connected?
    @conn.command cmd
  end

  #change map
  def clvl map
    command "changelevel #{ map }"
  end
  
  def cpswd pswd
    command "password #{ pswd }"
  end
  
  def connected?
    @connected
  end
  
  def used?
    status = command "status"
    return status[/players : (.*) \(/, 1] > Variables::Server_used
  end
  
  def to_s
    "connect #{ @ip }:#{ @port }; password #{ @pswd }"
  end
end
