require 'fileutils'
require 'net/ftp'
require 'zip/zipfilesystem'

require_relative '../database'
require_relative 'match'

class Server
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  
  property :host, String, :format => :url
  property :port, Integer, :gt => 0
  property :pass, String
  property :rcon, String, :required => true
  
  property :ftp_user, String
  property :ftp_pass, String
  property :ftp_dir, String
  
  has n, :matches
  
  property :played_at, DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  def server_obj
    SourceServer.new @host, @port
  end
  
  def start map
    server = server_obj
    info = server.server_info
    
    raise Exception.new("Could not connect") unless info
    raise Exception.new("Server is full") unless info['number_of_players'] < 6 # TODO: const['settings']['used']
    
    server.rcon_connect @rcon
    server.rcon_exec "changelevel #{ map.file }"
    server.rcon_disconnect
  
    return true
  end
  
  # TODO: Colourize scores
  def status 
    server = server_obj
    info = server.server_info
    
    return "empty" unless info and info['number_of_players'] > 0
    
    server.rcon_connect @rcon
    rinfo = Hash[server.rcon_exec("tournament_info").scan(/(\w+): "([^"]*)"/)]
    
    status = case rinfo
      when r.empty?; "warmup on #{ info['map_name'] } with #{ info['number_of_players'] } players"
      else; "#{ rinfo['Score'] } on #{ info['map_name'] } with #{ rinfo['Timeleft'] } remaining"
    end
    
    server.rcon_disconnect
    return status
  end
  
  def download_demos 
    server = server_obj
    info = server.server_info
    
    raise Exception.new("In use, please wait until the pug has ended") if info["number_of_players"] >= const["settings"]["used"]
    
    storage = "demos/" # TODO: Make a constant
    FileUtils.mkdir storage if not Dir.exists?(storage)
    
    down = Net::FTP.open(@host, @ftp_user, @ftp_pass)
    down.chdir @ftp_dir if @ftp_dir
    down.passive = true
    
    demos = conn.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
    demos.each do |filename|
      file = "#{ @name }-#{ filename }"
      filezip = "#{ file }.zip"
    
      down.getbinaryfile filename, storage + filename
      Zip::ZipFile.open(storage + filezip, Zip::ZipFile::CREATE) { |zipfile| zipfile.add(filename, storage + filename) }
      
      FileUtils.rm storage + filename
      down.delete filename
    end
    
    return demos.size
  end
  
  def connect_info
    "connect #{ @host }:#{ @port }; password #{ @password }"
  end
end
