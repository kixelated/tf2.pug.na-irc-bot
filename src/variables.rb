require './constants.rb'

module Variables
  include Constants

  def setup
    @servers = const["servers"].values.collect do |server|
      new Server(server)
    end
  
    @server = @servers.first
    @map = const["maps"].first
  
    @players = {}
    @spoken = {}
    @afk = []

    @captains = []
    @teams = []
    @lookup = {}
    
    @last = nil
    @state = const["states"]["waiting"]
    @pick = 0
  end
end