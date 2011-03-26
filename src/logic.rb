require_relative 'database'

require_relative 'logic/afk'
require_relative 'logic/players'
require_relative 'logic/picking'
require_relative 'logic/server'

class Logic
  include DataMapper::Resource
  
  include AfkLogic
  include PlayersLogic
  include PickingLogic
  include ServerLogic
  
  belongs_to :map
  belongs_to :server
  
  property :pick, Integer
  
  is :state_machine, :initial => :waiting, :column => :step do
    state :waiting, :enter => :start_waiting
    state :afk,     :enter => :start_afk
    state :picking, :enter => :start_picking
    state :match,  :enter => :start_match

    event :forward do
      transition :from => :waiting, :to => :afk
      transition :from => :afk,     :to => :picking
      transition :from => :picking  :to => :match
      transition :from => :match    :to => :waiting
    end
  end
  
  def start_waiting
    update(:map => choose_map, :server => choose_server)
  end
  
  def attempt_afk
    forward! if @step == "waiting" and minimum_players?
  end
  
  def start_afk
    forward!
    
    # TODO: Everything afk-based
    # message "#{ colourize rjust("AFK players:"), :yellow } #{ afk * ", " }"
  end
  
  def attempt_picking
    forward! if @step == "afk" and @afk.empty
  end
  
  def start_picking
    update(:pick => 0)
  
    message colourize "Teams are being drafted, captains will be selected in #{ Constants.delays['picking'] } seconds", :yellow
    sleep Constants.delays['picking']
  end
  
  def attempt_match
    forward! if @step == "picking" and @pick == 10 # (6 - 1) * 2
  end
  
  def start_match
    start_server @map
    forward!
  end
end
