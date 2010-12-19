require '../server.rb'

module ServerLogic
  def start_server
    @server.connect
    
    while @server.in_use?
      message "Server #{ @server.to_s } is in use. Trying the next server in #{ const["delays"]["server"] } seconds."
      
      sleep const["delays"]["server"]
      
      next_server
      @server.connect
    end
    
    @server.clvl @map
    @server.cpswd @server.pswd
    @server.command "sm_rtv_initialdelay 30.0" # TODO: Test this, people have reported it doesn't work.
  end
  
  def announce_server
    message "The pug will take place on #{ @server.to_s } with the map #{ @map }."
    advertisement
  end
  
  def change_map map
    @map = map
  end
  
  def change_server ip, port, pass, rcon
    @server = Server.new(ip, port, pass, rcon)
  end

  def list_server
    message "#{ @server.connect_info }"
    advertisement
  end  
  
  def list_map
    message "The current map is #{ @map }"
  end
  
  def list_mumble
    message "Mumble server info: #{ const["mumble"]["ip"] }:#{ const["mumble"]["port"] } #{ "password: #{ const["mumble"]["password"] }" if const["mumble"]["password"] }"
    advertisement
  end
  
  def list_last
    return message "A match has not been played since the bot was restarted." unless @last
    time = (Time.now - @last).to_i
    
    return message "The last match was started #{ time / 3600 } hours and #{ time / 60 % 60 } minutes ago"
  end
  
  def next_server
    return @server = @servers.first unless @servers.include? @server
    @server = @servers[(@servers.index(@server) + 1) % @servers.size]
  end
  
  def next_map
    return @map = const["maps"].first unless const["maps"].include? @map
    @map = const["maps"][(const["maps"].index(@map) + 1) % const["maps"].size]
  end
  
  def advertisement
    message "Servers are provided by #{ colourize "End", const["colours"]["orange"] } of #{ colourize "Reality", const["colours"]["orange"] }: #{ colourize "http://eoreality.net", const["colours"]["orange"] } #eoreality"
  end
end
