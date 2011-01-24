require 'net/ftp'
require 'fileutils'
require 'zip/zipfilesystem'

require_relative 'constants'

class STV
  include Constants

  def initialize server
    @server = server
  end

  def open details
    Net::FTP.open(details["ip"], details["user"], details["password"]).tap do |conn|
      conn.passive = true
      conn.chdir details["dir"] if details["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def demos conn = @down
    conn.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
  end
  
  def update server
    demos.each do |filename|
      file = "#{ server.name }-#{ filename }"
      filezip = "#{ file }.zip"
      filetemp = "#{ file }.tmp"

      storage = "#{ const["stv"]["storage"] }"

      # Download file and zip it
      @down.getbinaryfile filename, storage + filename
      Zip::ZipFile.open(storage + filezip, Zip::ZipFile::CREATE) { |zipfile| zipfile.add(filename, storage + filename) }

      # Upload the file with a temp file extension and rename it after uploading
      @up.putbinaryfile storage + filezip, filetemp
      @up.rename filetemp, filezip
      
      # Delete local files
      FileUtils.rm storage + filename
      FileUtils.rm storage + filezip if const["stv"]["delete"]["local"]

      # Delete remote files
      @down.delete filename if const["stv"]["delete"]["remote"]
    end
  end
  
  def purge
    demos(@up).each do |filename|
      if filename =~ /(.+?)-(.{4})(.{2})(.{2})-(.{2})(.{2})-(.+?)\.dem/
        server, year, month, day, hour, min, map = $1, $2, $3, $4, $5, $6, $7
        @up.delete filename if Time.mktime(year, month, day, hour, min) + 1209600 < Time.now
      end
    end
  end
  
  def connect
    @up = open const["stv"]["ftp"]
    @down = open @server
  end
  
  def disconnect
    close @up
    close @down
  end
end
