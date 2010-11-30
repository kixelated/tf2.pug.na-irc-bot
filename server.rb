class Server
	attr_accessor :ip, :port, :pswd
		
		rcon = "squid"
		
		def initialize ip, port, pswd
			@ip = ip
			@port = port
			@pswd = pswd
		end
		
		#establish connection to server and auth
		def connect 
			conn = RCon::Query::Source.new(@ip, @port)
			conn.auth rcon
		end
		
		#change map
		def clvl
			conn.command("changelevel #{ServerLogic::current_map}")
		end
		
		#execute any command passed
		def command cmd
			conn.command(cmd)
		end
	
end
