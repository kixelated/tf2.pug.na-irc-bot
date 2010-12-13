require './server.rb'

module Const
  Irc_server = "irc.gamesurge.net"
  Irc_port = 6667

  Irc_vhost = nil # "zomgbbq.com"
  Irc_channel = "#tf2.pug.na.beta"
  
  Messenger_count = 1
  Nick_bot = "IRCCompanionTest"
  Nick_messenger = "IRCMessengerTes"

  Afk_threshold = 10 * 60
  Afk_delay = 45
  Server_delay = 30
  Picking_delay = 45
  Message_delay = 0.1

  Team_count = 2
  Team_names = [ "Blue", "Red" ]
  Team_colours = [ 11, 4 ]
  Team_size = 6
  Team_classes = { "scout" => 2, "soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 }
  
  Dallas1 = Server.new("dallas1.tf2pug.eoreality.net", 27015, "tf2pug", "secret")
  Chicago1 = Server.new("chicago1.tf2pug.eoreality.net", 27015, "tf2pug", "secret")

  Servers = [ Chicago1, Dallas1 ]
  Maps = [ "cp_badlands", "cp_granary", "koth_viaduct", "cp_coldfront", "cp_gullywash_imp3" ]

  Server_used = 6
  
  State_waiting = 0
  State_afk = 1
  State_delay = 2
  State_picking = 3
  State_server = 4
  
  White = 0
  Black = 1
  Navy = 2
  Green = 3
  Red = 4
  Brown = 5
  Purple = 6
  Olive = 7
  Yellow = 8
  Lime = 9
  Teal = 10
  Aqua = 11
  Royal = 12
  Pink = 13
  Darkgrey = 14
  Lightgrey = 15
  
  Justify = 15
end

module Variables
  def setup

    @server = Const::Servers.first
    @map = Const::Maps.first
  
    @players = {}
    @spoken = {}
    @afk = []

    @captains = []
    @teams = []
    @lookup = {}
    
    @last = nil
    @state = Const::State_waiting
    @pick = 0
  end
end