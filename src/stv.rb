require 'net/ftp'
require 'fileutils'
require 'zippy'

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
  
  def demos
    @down.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
  end
  
  def update server
    demos.each do |filename|
      file = "#{ server.name }/#{ filename }"
      filezip = "#{ file }.zip"
      fileup = "#{ file }.temp"

      # Download file and zip it
      @down.getbinaryfile filename, filename
      Zippy.create(filezip, filename => File.open(filename))

      # Upload the file with a temp file extension and rename it after uploading
      @up.putbinaryfile filezip, fileup
      @up.rename fileup, filezip
      
      # Move or delete local files
      FileUtils.mv filezip, const["stv"]["storage"] + filezip unless const["stv"]["delete"]["local"]
      FileUtils.rm [ filename, filezip ], :force => true
      
      # Delete remote files
      @down.delete filename if const["stv"]["delete"]["remote"]
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
