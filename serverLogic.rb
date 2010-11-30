require 'rcon'

module ServerLogic
  def start_server
    conn = RCon::Query::Source.new(current_server[0], current_server[1])
    if conn.auth current_server[3]
      conn.command("changelevel #{current_map}")
    end
  
    @servers.push @servers.shift
    @maps.push @maps.shift
  end
  
  def connect_info
    "connect #{ current_server[0] }:#{ current_server[1] }; password #{ current_server[2] }"
  end
  
  def list_server
    msg connect_info
  end  
  
  def list_map
    msg "The current map is #{ current_map }"
  end

  def current_server
    @servers.first
  end
  
  def current_map
    @maps.first
  end
end