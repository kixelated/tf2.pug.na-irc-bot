require 'chronic_duration'
require 'fileutils'
require 'net/ftp'

require_relative '../model/map'
require_relative '../model/server'

module ServerLogic
  def find_server
    servers = Server.all(:order => :played_at.asc)
  
    servers.each do |server|
      2.times do |i|
        begin
          return server if server.start(@map)
        rescue Exception => e
          message "#{ e.message } while connecting to #{ server.name }."
          sleep const["delays"]["server"]
        end
      end
    end
  end
  
  def announce_server
    message "The pug will take place on #{ @server.name } with the map #{ @map.name }."
    advertisement
  end
  
  def next_map
    maps = Map.all(:order => :played_at.desc, :limit => (Map.count - const['rotation']['exclude']))
    num = rand(maps.sum(:weight))
    
    maps.each do |map|
      num -= map.weight
      return map if num <= 0
    end
  end

  def update_stv
    Server.all.each do |server|
      begin
        result = server.download_demos
        upload_demos
        purge_demos
        
        message "#{ server.name }: #{ result } demos uploaded"
      rescue Exception => e
        message "#{ server.name }: #{ e.message }"
      end
    end
  end
  
  def upload_demos
    storage = "demos/" # TODO: Make constant
  
    up = Net::FTP.open(const["stv"]["ftp"]["ip"], const["stv"]["ftp"]["user"], const["stv"]["ftp"]["password"]) # TODO: Clean up constants
    up.chdir const["stv"]["ftp"]["dir"] if const["stv"]["ftp"]["dir"]
    up.passive = true
  
    Dir.new(storage).glob("*.zip").each do |filename|
      up.putbinaryfile storage + filename, filename + ".tmp"
      up.rename filename + ".tmp", filename
      
      FileUtils.rm storage + filename
    end
  end
  
  def purge_demos
    up = Net::FTP.open(const["stv"]["ftp"]["ip"], const["stv"]["ftp"]["user"], const["stv"]["ftp"]["password"]) # TODO: Clean up constants
    up.chdir const["stv"]["ftp"]["dir"] if const["stv"]["ftp"]["dir"]
  
    up.nlst.each do |filename|
      if filename =~ /(.+?)-(.{4})(.{2})(.{2})-(.{2})(.{2})-(.+)\.dem/
        server, year, month, day, hour, min, map = $1, $2, $3, $4, $5, $6, $7
        up.delete filename if Time.mktime(year, month, day, hour, min) + 1209600 < Time.now # TODO: Make constant
      end
    end
  end
  
  def list_stv
    message "STV demos can be found here: #{ const['stv']['url'] }"
  end
  
  def list_status
    Server.all.each do |server|
      message "#{ server.name }: #{ server.status }"
    end
  end

  def list_server
    server = Server.first(:order => :played_at.asc)
    message "#{ server.name }: #{ server.connect_info }"
    advertisement
  end
  
  def list_map
    message "The current map is #{ @map.name }"
  end
  
  def list_mumble
    message "Mumble server info: #{ const['mumble']['ip'] }:#{ const['mumble']['port'] } password: #{ const['mumble']['password'] } . Download Mumble here: http://mumble.sourceforge.net/"
    advertisement
  end
  
  def list_last
    message "The last match was started #{ ChronicDuration.output(Time.now - Server.max(:played_at)) } ago"
  end
  
  def list_rotation
    output = Map.all.collect { |map| "#{ map.name }(#{ map.weight })" }
    message "Map(weight) rotation: #{ output * ", " }"
  end
  
  def advertisement
    message "Servers are provided by #{ colourize "End", const['colours']['orange'] } of #{ colourize "Reality", const['colours']['orange'] }: #{ colourize "http://eoreality.net", const['colours']['orange'] } #eoreality"
  end
end
