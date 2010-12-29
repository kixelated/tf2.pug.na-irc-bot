require_relative 'stv'
require_relative 'server'
require_relative 'constants'

Constants.const["servers"].each do |server_d|
  server = Server.new server_d
  
  unless server.in_use?
    stv = STV.new server_d["ftp"]
    
    count = stv.demos.size
    puts "Uploading #{ count } demos from #{ server.to_s }."
    
    stv.update if count
    stv.disconnect
  else
    puts "#{ server.to_s } is currently in use."
  end
  
  server.close
end

STV.disconnect
