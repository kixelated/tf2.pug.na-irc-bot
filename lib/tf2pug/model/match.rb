require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/map'
require 'tf2pug/model/matchup'
require 'tf2pug/model/server'

class Match
  include DataMapper::Resource
  
  property :id, Serial
  property :type, Discriminator

  belongs_to :map
  belongs_to :server
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  is :state_machine, :initial => :setup, :column => :state do
    state :setup
    state :warmup,  :enter => :start_match
    state :live
    state :final,   :enter => :end_match
    
    event :forward do
      transition :from => :setup,   :to => :warmup
      transition :from => :warmup,  :to => :live
      transition :from => :live,    :to => :final
    end
  end

  has 2, :matchups
  has 2, :teams,    :through => :matchups
  
  def home; matchups.first(:home => true); end
  def away; matchups.first(:home => false); end
  
  def start_match
    @server.start(@map) # if an exception is thrown, the state never gets updated
  end
  
  def end_match
    # TODO
  end
  
  # TODO: optional block can be used instead
  def get_matchup(index = nil, &block)
    index = block.call(self) unless index
    self.matchups.get(index)
  end
end
