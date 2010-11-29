require 'rcon'

module ServerLogic
  def start_server
    conn = RCon::Query::Source.new("#{current_server[0]}", current_server[1])
    if conn.auth("#{current_server[2]}")
      puts conn.command("changelevel #{current_map}")
    end
  
    @server_index = (@server_index + 1) % @servers.size
    @map_index = (@map_index + 1) % @maps.size
  end
  
  def list_server
    msg "connect #{ current_server[0] }:#{ current_server[1] }; password tf2pug"
  end  
  
  def list_map
    msg "The current map is #{ current_map }"
  end

  def current_server
    @servers[@server_index]
  end
  
  def current_map
    @maps[@map_index]
  end
end