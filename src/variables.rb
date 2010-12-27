require_relative 'constants'
require_relative 'server'

module Variables
  include Constants

  def setup
    @server = Server.new const["servers"].first
    @prev_maps = []
    next_map
  
    @signups = {}
    @auth = {} # A backup of nicks to authnames in case somebody disconnects during picking
    @spoken = {}
    @afk = []

    @teams = []
    @lookup = {}
    
    @last = nil
    @state = const["states"]["waiting"]
    @pick = 0
  end
end
