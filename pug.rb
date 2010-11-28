require './playersLogic.rb'
require './pickingLogic.rb'
require './util.rb'

class Pug
  include Cinch::Plugin
  include PlayersLogic
  include PickingLogic
  
  listen_to :part, method: :part
  
  match /add (.+)/, method: :add
  match /remove/, method: :remove
  match /list/, method: :list
  
  match /pick (.+) (.+)/, method: :pick
  match /captain/, method: :captain
  
  match /test/, method: :test

  def initialize *args
    super
    setup
  end
  
  def setup
    @players = {}

    @team_size = 3
    @team_classes = { "scout" => 3, "soldier" => 0, "demo" => 0, "medic" => 0, "captain" => 1 }
    
    start_game
  end
  
  def start_game
    @captains = []
    @teams = []
    
    @state = 0 # 0 = add/remove, 1 = delay, 2 = picking
    @pick = 0
    @pick_index = 0
  end
  
  def part m
    list_players if remove_player m.user
  end

  # !add
  def add m, args
    if add_player m.user, args.split(/ /)
      list_players
      start_picking
    end
  end

  # !remove
  def remove m
    list_players if remove_player m.user
  end
  
  # !list
  def list m
    list_players_detailed
  end
  
  # !pick
  def pick m, arg1, arg2
    pick_player m.user, User(arg1), arg2
  end
  
  # !captain
  def captain m
    list_captain m.user
  end

  def msg message
    bot.msg "#tf2.pug.na.beta", "\x02" + message + "\x02"
  end
  
  def priv user, message
    bot.msg user, message
  end
end