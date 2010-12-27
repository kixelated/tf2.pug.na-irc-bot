require 'net/ftp'
require 'fileutils'
require_relative 'constants'
require_relative 'model/match'

storage = Constants.const["stv"]
servers = Constants.const["servers"]

puts "Establishing a connection to #{ storage["ip"] }"

up = Net::FTP.new storage["ip"]
up.login storage["ftp"]["user"], storage["ftp"]["password"]
up.chdir storage["ftp"]["dir"] if storage["ftp"]["dir"]

servers.each do |server|
  puts "Establishing a connection to #{ server["name"] }"

  down = Net::FTP.new server["ip"]
  down.login server["ftp"]["user"], server["ftp"]["password"]
  down.chdir server["ftp"]["dir"] if server["ftp"]["dir"]
  
  filepath = "../stv/#{ server["name"] }"
  
  down.nlst.each do |filename|
    if filename =~ /.+\.dem/
      file = filepath + filename
    
      puts "Downloading #{ filename }"
      down.getbinaryfile filename, file
      
      puts "Deleting #{ filename }"
      down.delete filename
      
      puts "Uploading #{ filename }"
      up.putbinaryfile file, filename
    end
  end
end
