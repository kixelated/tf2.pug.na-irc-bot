require './playersLogic.rb'
require './pickingLogic.rb'
require './stateLogic.rb'
require './serverLogic.rb'
require './util.rb'

class Pug
  include Cinch::Plugin
  include PlayersLogic
  include PickingLogic
  include StateLogic
  include ServerLogic
  
  listen_to :part, method: :part
  listen_to :quit, method: :part
  
  match /add (.+)/, method: :add
  match /remove/, method: :remove
  match /list/, method: :list
  match /players/, method: :list
  match /need/, method: :need
  
  match /pick (.+)/, method: :pick
  match /captain/, method: :captain
  
  match /mumble/, method: :mumble
  match /map/, method: :map
  match /server/, method: :server

  def initialize *args
    super
    setup
  end
  
  # variables that do not reset between pugs
  def setup
    @channel = "#tf2.pug.na.beta"
    
    @servers = [["chicago1.tf2pug.org", 27015, "tf2pug", "squid"]]
    @maps = ["cp_badlands", "cp_granary"]
  
    @players = {}
    @afk = []

    start_game
  end
  
  # variables that reset between pugs
  def start_game
    @captains = []
    @teams = []

    @state = 0 # 0 = add/remove, 1 = afk check, 2 = delay, 3 = picking
    @pick = 0
  end

  def part m
    list_players if remove_player m.user
  end

  # !add
  def add m, args
    if add_player m.user, args.split(/ /)
      list_players
      attempt_afk # checks if minimum requirements are met
    end
  end

  # !remove
  def remove m
    list_players if remove_player m.user
  end
  
  # !list
  def list m
    list_players
    list_players_detailed
  end
  
  # !need
  def need m
    list_classes_needed
  end
  
  # !pick
  def pick m, args
    pick_player m.user, args.split(/ /)
  end
  
  # !captain
  def captain m
    list_captain m.user
  end
  
  # !mumble
  def mumble m
    msg "The Mumble IP is 'tf2pug.commandchannel.com:30153' (password 'tf2pug')"
    msg "Download Mumble here: http://mumble.sourceforge.net/"
  end
  
  # !map
  def map m
    list_map
  end
  
  # !server
  def server m
    list_server
  end
  
  def colour_start foreground, background = 0
    "\x03#{ foreground.to_s.rjust(2, "0") },#{ background.to_s.rjust(2, "0") }"
  end
  
  def colour_end
    "\x03"
  end
  
  def colour_default
    colour_start(0, 2)
  end
  
  def make_title message, background = 1
    colour_start(0, background) + (" " + message).rjust(15) + colour_end
  end

  def message channel = @channel, msg
    bot.msg channel, msg
  end
  
  def notice channel = @channel, msg
    bot.notice user, msg
  end
end