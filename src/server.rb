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
    return unless connected? 
    @conn.command cmd
  end
  
  def cvar name
    return unless connected?
    @conn.cvar name
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
  
  def in_use?
    command("status") =~ /players : (\S+) /
    return $1.to_i > const["settings"]["used"]
  end
  
  def connect_info
    "connect #{ @ip }:#{ @port }; password #{ @pswd }"
  end
  
  def to_s
    "#{ @ip }:#{ @port }"
  end
end
