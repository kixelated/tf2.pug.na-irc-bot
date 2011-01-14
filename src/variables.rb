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
    
    @toadd = {}
    @toremove = []

    @teams = []
    @pick_order = []
    @lookup = {}
    
    @last = Match.last.time if Match.last
    @state = const["states"]["waiting"]
    @pick = 0
    
    @updating = false
    @debug = false
  end
  
  def end_game
    @teams.clear
    @lookup.clear

    @last = Time.now
    state "waiting"
    @pick = 0
    @pick_order = []
    
    @auth.reject! { |k, v| !@signups.key? k }
    @spoken.reject! { |k, v| !@signups.key? k }
    
    @toadd.each { |nick, classes| add_player nick, classes }
    @toremove.each { |nick| remove_player nick }
    
    @toadd.clear
    @toremove.clear

    next_server
    next_map
  end
end
