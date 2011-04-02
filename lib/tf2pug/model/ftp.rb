require 'fileutils'
require 'zip/zipfilesystem'

require 'net/ftp'

require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/server'

class Ftp
  include DataMapper::Resource
  
  property :id,   Serial
  property :host, String, :required => true
  
  property :user, String # TODO: Set default anonymous details
  property :pass, String
  property :dir,  String
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has 1, :server
  
  def connect
    Net::FTP.open(@host, @user, @pass) do |conn| # TODO: Double check
      conn.chdir @dir if @dir
      conn.passive = true
      yield conn
    end
  end
  
  def download_demos prefix
    storage = Constants.stv['storage']
    FileUtils.mkdir storage if not Dir.exists?(storage)
    
    connect do |conn|
      demos = conn.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
      demos.each do |filename|
        file = "#{ prefix }-#{ filename }"
        filezip = "#{ file }.zip"
      
        conn.getbinaryfile filename, storage + filename
        Zip::ZipFile.open(storage + filezip, Zip::ZipFile::CREATE) do |zipfile| 
          zipfile.add(filename, storage + filename)
        end
        
        FileUtils.rm storage + filename
        conn.delete filename
        
        return demos.size
      end
    end
  end
  
  def upload_demos
    storage = Constants.stv['storage']
    FileUtils.mkdir storage if not Dir.exists?(storage)
  
    files = Dir[storage + "*.zip"]
    
    if files.size > 0
      connect do |conn|
        files.each do |file|
          filename = File.basename(file)
          
          conn.putbinaryfile file, filename + ".tmp"
          conn.rename filename + ".tmp", filename
          
          FileUtils.rm file
        end
      end
    end  
    
    return files.size
  end
  
  def purge_demos
    connect do |conn|
      conn.nlst.each do |filename|
        if filename =~ /(.+?)-(.{4})(.{2})(.{2})-(.{2})(.{2})-(.+)\.dem/
          server, year, month, day, hour, min, map = $1, $2, $3, $4, $5, $6, $7
          conn.delete filename if Time.mktime(year, month, day, hour, min) + Constants.stv['purge'] < Time.now
        end
      end
    end
  end
end
