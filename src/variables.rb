require_relative 'constants'
require_relative 'server'

module Variables
  include Constants

  def setup
    @server = Server.new const["servers"].first
    @prev_maps = []
    next_map
  
    @signups = {}
    @signups_all = {}
    @auth = {}
    @spoken = {}
    @afk = []
    @toremove = []

    @teams = []
    @lookup = {}
    
    @last = Match.last.time if Match.last
    @state = const["states"]["waiting"]
    @pick = 0
    
    @updating = false
    @debug = false
  end
end
