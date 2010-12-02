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
  
  match /changemap (.+)/, method: :change_map
  match /force (.+)/, method: :admin_force

  def initialize *args
    super
    setup # variables.setup
  end

  # (quit)
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
    message "The Mumble IP is 'tf2pug.commandchannel.com:30153' (password 'tf2pug')"
    message "Download Mumble here: http://mumble.sourceforge.net/"
  end
  
  # !map
  def map m
    list_map
  end
  
  # !server
  def server m
    list_server
  end

  # !changemap
  def change_map m, new_map
    return unless require_admin m.user
    
	return notice m.user, "That map does not exist or is not in the rotation. Valid maps are: " + @maps.join(", ") if not @maps.index(new_map)
	
	@maps.delete new_map
	@maps.insert(0, new_map)
	
	list_map
  end

  # !force
  def admin_force m, args
    return unless require_admin m.user
    
    temp = args.split(/ /)
    user = User(temp.shift)

    if add_player user, temp
      list_players
      attempt_afk
    end
  end
  
  def require_admin user
    return notice user, "That is an admin-only command." unless Channel(@channel).opped? user
    true
  end

  def message msg
    bot.msg @channel, colour_start(0) + msg + colour_end
    false
  end
  
  def private user, msg
    bot.msg user, msg
    false
  end
  
  def notice channel = @channel, msg
    bot.notice channel, msg
    false
  end
end