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
  
  match /force (.+)/, method: :admin_force

  def initialize *args
    super
    setup # variables.rb
  end

  # (quit)
  def part m
    list_players if remove_player m.user # playersLogic.rb
  end

  # !add
  def add m, args
    if add_player m.user, args.split(/ /) # playersLogic.rb
      list_players # playersLogic.rb
      attempt_afk # stateLogic.rb
    end
  end

  # !remove
  def remove m
    list_players if remove_player m.user # playersLogic.rb
  end
  
  # !list
  def list m
    list_players # playersLogic.rb
    list_players_detailed
  end
  
  # !need
  def need m
    list_classes_needed # playersLogic.rb
  end
  
  # !pick
  def pick m, args
    pick_player m.user, args.split(/ /) # pickingLogic.rb
  end
  
  # !captain
  def captain m
    list_captain m.user # pickingLogic.rb
  end
  
  # !mumble
  def mumble m
    message "The Mumble IP is 'tf2pug.commandchannel.com:30153' (password 'tf2pug')"
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
  
  # !force
  def admin_force m, args
    return unless require_admin m
    
    temp = args.split(/ /)
    user = User(temp.shift)

    if add_player user, temp # playersLogic.rb
      list_players # playersLogic.rb
      attempt_afk # stateLogic.rb
    end
  end
  
  def require_admin m
    return notice m.user, "That is an admin-only command." unless m.channel.opped? m.user
    true
  end

  def message msg
    bot.msg @channel, colour_start(0) + msg + colour_end # util.rb
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