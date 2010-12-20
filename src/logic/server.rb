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
    
    @server.clvl @map["file"]
    @server.cpswd @server.pswd
    @server.command "sm_rtv_initialdelay 30.0" # TODO: Test this, people have reported it doesn't work.
    
    @last_maps << @map
    @last_maps.shift if @last_maps.size > const["rotation"]["exclude"]
  end
  
  def announce_server
    message "The pug will take place on #{ @server.to_s } with the map #{ @map["name"] }."
    advertisement
  end
  
  def change_map map
    @map = map
  end

  def list_server
    message "#{ @server.connect_info }"
    advertisement
  end  
  
  def list_map
    message "The current map is #{ @map["name"] }"
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
  
  def list_rotation
    output = const["rotation"]["maps"].collect { |map| "#{ map["name"] }(#{ map["weight"] })" }
    message "Map(weight) rotation: #{ output.join(", ") }"
  end
  
  def next_server
    @server = @servers[(@servers.index(@server) + 1) % @servers.size]
  end
  
  def next_map 
    maps = const["rotation"]["maps"].reject { |map| @last_maps.include? map }
   
    weight = 0
    maps.each { |map| weight += map["weight"] }
  
    num = rand weight
    maps.each do |map|
      num -= map["weight"]
      return (@map = map) if num < 0
    end
  end
  
  def advertisement
    message "Servers are provided by #{ colourize "End", const["colours"]["orange"] } of #{ colourize "Reality", const["colours"]["orange"] }: #{ colourize "http://eoreality.net", const["colours"]["orange"] } #eoreality"
  end
end
