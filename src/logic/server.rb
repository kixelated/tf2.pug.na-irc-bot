require 'chronic_duration'

require_relative '../server'
require_relative '../stv'

module ServerLogic
  def start_server
    @server.connect
    
    while @server.in_use?
      message "Server #{ @server.to_s } is in use. Trying the next server in #{ const["delays"]["server"] } seconds."
      @server.disconnect
      
      sleep const["delays"]["server"]
      
      next_server
      @server.connect
    end
    
    @server.clvl @map["file"]
    @server.cpswd @server.password
    @server.disconnect
  end
  
  def announce_server
    message "The pug will take place on #{ @server.to_s } with the map #{ @map["name"] }."
    advertisement
  end
  
  def change_map map
    @map = map
  end
  
  def each_server
    threads = []
    const["servers"].each do |server_d|
      threads << Thread.new(Server.new(server_d), server_d) do |server, server_d|
        server.connect
        yield server, server_d
        server.disconnect
      end
    end
    threads.each { |thread| thread.join }
  end
  
  def update_stv
    @updating = true
    
    each_server do |server, server_d|
      if server.in_use?
        message "#{ server } is in use, please wait until the pug has ended."
      else
        stv = STV.new server_d["ftp"]
        stv.connect
        
        count = stv.demos.size
        if count > 0
          message "Uploading #{ count } demos from #{ server }."
          stv.update server
        else
          message "No new demos on #{ server }."
        end
        
        stv.disconnect
      end
    end
    
    @updating = false
  end
  
  def list_stv
    message "STV demos can be found here: #{ const["stv"]["url"] }"
  end
  
  def list_status
    each_server do |server, server_d|
      message "#{ server.players - 1 } players on #{ server }" # -1 to factor in STV
    end
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
    message "The last match was started #{ ChronicDuration.output((Time.now - @last).to_i, :format => :long) } ago"
  end
  
  def list_rotation
    output = const["rotation"]["maps"].collect { |map| "#{ map["name"] }(#{ map["weight"] })" }
    message "Map(weight) rotation: #{ output * ", " }"
  end
  
  def next_server
    temp = const["servers"].push(const["servers"].shift).first
    @server = Server.new temp
  end
  
  def next_map 
    @prev_maps << @map
    @prev_maps.shift if @prev_maps.size > const["rotation"]["exclude"]
  
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
