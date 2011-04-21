require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/map'
require 'tf2pug/model/matchup'
require 'tf2pug/model/server'

class Match
  include DataMapper::Resource
  
  property :id,   Serial
  property :type, Discriminator

  belongs_to :map
  belongs_to :server
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  is :state_machine, :initial => :setup, :column => :state do
    state :setup
    state :warmup, :enter => :start_match
    state :live
    state :final,  :enter => :end_match
    
    event :advance do
      transition :from => :setup,   :to => :warmup
      transition :from => :warmup,  :to => :live
      transition :from => :live,    :to => :final
    end
  end

  has 2, :matchups
  has 2, :teams,    :through => :matchups
  
  def home; self.matches.get(0); end
  def away; self.matches.get(1); end
  
  def start_match
    # note: if an exception is thrown, the state never gets updated
    @server.start(@map) 
  end
  
  def end_match
    
  end
end
