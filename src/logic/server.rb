require_relative '../server'
require_relative '../stv'

module ServerLogic
  def start_server
    while @server.in_use?
      message "Server #{ @server.to_s } is in use. Trying the next server in #{ const["delays"]["server"] } seconds."
      next_server
      
      sleep const["delays"]["server"]
    end
    
    @server.clvl @map["file"]
    @server.cpswd @server.password
    
    @prev_maps << @map
    @prev_maps.shift if @prev_maps.size > const["rotation"]["exclude"]
  end
  
  def announce_server
    message "The pug will take place on #{ @server.to_s } with the map #{ @map["name"] }."
    advertisement
  end
  
  def change_map map
    @map = map
  end
  
  def update_stv
    return message "Update already in progress" if @updating
  
    @updating = true
    const["servers"].each do |server_d|
      server = Server.new server_d
      
      unless server.in_use?
        stv = STV.new server_d["ftp"]
        
        count = stv.demos.size
        message "Uploading #{ count } demos from #{ server.to_s }."
        
        stv.update if count
        stv.disconnect
      else
        message "#{ server.to_s } is currently in use."
      end
      
      server.close
    end
    
    STV.disconnect
    
    @updating = false
  end
  
  def list_stv
    message "STV demos can be found here: #{ const["stv"]["url"] }"
  end

  def list_server
    message "#{ @server.connect_info }"
    advertisement
  end  
  
  def list_map
    message "The current map is #{ @map["name"] }"
  end
  
  def list_mumble
    message "Mumble server info: #{ const["mumble"]["ip"] }:#{ const["mumble"]["port"] } #{ "password: #{ const["mumble"]["password"] }" if const["mumble"]["password"] } . Download Mumble here: http://mumble.sourceforge.net/"
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
    temp = const["servers"].push(const["servers"].shift).first
    
    @server.close
    @server = Server.new temp
  end
  
  def next_map 
    maps = const["rotation"]["maps"].reject { |map| @prev_maps.include? map }
   
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
