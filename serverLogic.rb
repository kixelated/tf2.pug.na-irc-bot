require 'rcon'

module ServerLogic
  def start_server
    @state = Const::State_server

    begin
      while @server.in_use?
        message "Server #{ @server.to_s } is in use. Trying the next server in #{ Const::Server_delay } seconds."
        
        next_server
        sleep Const::Server_delay
      end

      @server.cpswd @server.pswd
      @server.clvl @map
    rescue
      message "Could not connect to #{ @server.to_s }, it may be down."
    end
  end
  
  def announce_server
    message "The pug will take place on #{ @server.to_s } with the map #{ @map }."
    message advertisement
  end
  
  def change_map map
    @map = map
  end
  
  def change_server ip, port, pass, rcon
    @server = Server.new(ip, port, pass, rcon)
  end

  def list_server
    message "#{ @server.connect_info }"
    message advertisement
  end  
  
  def list_map
    message "The current map is #{ @map }"
  end
  
  def list_last
    return message "A match has not been played since the bot was restarted." unless @last
    time = (Time.now - @last).to_i
    
    return message "The last match was started #{ time / 3600 } hours and #{ time / 60 % 60 } minutes ago"
  end
  
  def next_server
    return @server = Const::Servers.first unless Const::Servers.include? @server
    @server = Const::Servers[(Const::Servers.index(@server) + 1) % Const::Servers.size]
  end
  
  def next_map
    return @map = Const::Maps.first unless Const::Maps.include? @map
    @map = Const::Maps[(Const::Maps.index(@map) + 1) % Const::Maps.size]
  end
  
  def advertisement
    "Servers are provided by #{ colourize "End", Const::Colour_red } of #{ colourize "Reality", Const::Colour_red }: #{ colourize "http://eoreality.net", Const::Colour_red } #eoreality"
  end
end
