require './playersLogic.rb'
require './pickingLogic.rb'
require './stateLogic.rb'
require './serverLogic.rb'

require './team.rb'
require './server.rb'

require './variables.rb'
require './util.rb'

class Pug
  include Cinch::Plugin
  
  include Variables
  include Utilities
  
  include PlayersLogic
  include PickingLogic
  include StateLogic
  include ServerLogic
  
  listen_to :part, method: :remove
  listen_to :quit, method: :remove
  
  match /add (.+)/, method: :add
  match /remove/, method: :remove
  match /list/, method: :list
  match /players/, method: :list
  match /need/, method: :need
  
  match /pick ([\S]+) ([\S]+)/, method: :pick
  match /captain/, method: :captain
  
  match /map/, method: :map
  match /server/, method: :server
  
  match /man/, method: :help
  match /mumble/, method: :mumble
  
  match /force ([\S]+) (.+)/, method: :admin_force
  match /replace ([\S]+) ([\S]+)/, method: :admin_replace
  
  match /changemap ([\S]+)/, method: :admin_changemap
  match /changeserver ([\S]+) ([\S]+) ([\S]+) ([\S]+)/, method: :admin_changeserver
  match /nextmap/, method: :admin_nextmap
  match /nextserver/, method: :admin_nextserver

  def initialize *args
    super
    setup # variables.rb 
  end

  # !add
  def add m, args
    if add_player m.user, args.split(/ /) # playersLogic.rb
      list_players # playersLogic.rb
      attempt_afk # stateLogic.rb
    end
  end

  # !remove, (quit), (part)
  def remove m
    list_players if remove_player m.user # playersLogic.rb
  end
  
  # !list, !players
  def list m
    list_players # playersLogic.rb
    list_players_detailed
  end
  
  # !need
  def need m
    list_classes_needed # playersLogic.rb
  end
  
  # !pick
  def pick m, player, player_class
    pick_player m.user, User(player), player_class # pickingLogic.rb
  end
  
  # !captain
  def captain m
    list_captain m.user # pickingLogic.rb
  end
  
  # !mumble
  def mumble m
    message "The Mumble IP is: chi6.eoreality.net:64746 password: tf2pug"
    message "Download Mumble here: http://mumble.sourceforge.net/"
  end

  # !map
  def map m
    list_map # serverLogic.rb
  end
  
  # !server
  def server m
    list_server # serverLogic.rb
  end
  
  # !man
  def help m
    message "The avaliable commands are: !add, !remove, !list, !need, !pick, !captain, !mumble, !map, !server"
  end

  # !changemap
  def admin_changemap m, map
    return unless require_admin m
    
    change_map map
    list_map
  end
  
  # changeserver
  def admin_changeserver m, ip, port, pass, rcon
    return unless require_admin m
    
    change_server ip, port, pass, rcon
    list_server
  end
  
  # !nextmap
  def admin_nextmap m
    return unless require_admin m
    
    next_map
    list_map
  end
  
  # !nextserver
  def admin_nextserver m
    return unless require_admin m
    
    next_server
    list_server
  end

  # !force
  def admin_force m, player, args
    return unless require_admin m
    
    if add_player User(player), args.split(/ /) # playersLogic.rb
      list_players # playersLogic.rb
      attempt_afk # stateLogic.rb
    end
  end
  
  def admin_replace m, user, replacement
    return unless require_admin m
    
    replace_player User(user), User(replacement) # pickingLogic.rb
    list_players # playersLogic.rb
  end
  
  def require_admin m
    return notice m.user, "That is an admin-only command." unless m.channel.opped? m.user
    true
  end

  def message msg
    MasterMessenger.instance.msg Const::Irc_channel, colour_start(0) + msg + colour_end # util.rb
    false
  end
  
  def private user, msg
    MasterMessenger.instance.msg user, msg
    false
  end
  
  def notice channel = Const::Irc_channel, msg
    MasterMessenger.instance.notice channel, msg
    false
  end
end