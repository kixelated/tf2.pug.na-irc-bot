require_relative 'constants'
require_relative 'server'
require_relative 'model/match'

module Variables
  include Constants

  def setup
    @servers = const["servers"].collect { |details| Server.new details }
    @servers.select! { |server| begin; server.authorize; rescue; false; end }
    @prev_maps = []
    
    next_server
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

    @show_list = 0
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
    
    @toadd.each { |nick, classes| add_player User(nick), classes }
    @toremove.each { |nick| remove_player User(nick) }
    
    @toadd.clear
    @toremove.clear

    next_server
    next_map
  end
end
