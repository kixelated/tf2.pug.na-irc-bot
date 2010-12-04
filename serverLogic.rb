require 'rcon'

module ServerLogic
  def start_server
    @state = Variables::State_server

    while @server.in_use?
      message "Server #{ @server.to_s } is in use. Trying the next server in #{ Variables::Server_delay } seconds."
      
      next_server
      sleep Variables::Server_delay
    end

    @server.cpswd @server.pswd
    @server.clvl @map
    
    message "The pug will take place on #{ @server.to_s } with the map #{ @map }"
    message advertisement
  end
  
  def change_map map
    @map = map
  end

  def list_server
    message "#{ @server.connect_info }"
    message advertisement
  end  
  
  def list_map
    message "The current map is #{ @map }"
  end
  
  def next_server

  end
  
  def next_map
  
  end
  
  def advertisement
    "Servers are provided by #{ colourize "EoReality", 7 }: #{ colourize "http://eoreality.net", 7 }"
  end
end
