require 'tf2pug/database'
require 'tf2pug/model/map'
require 'tf2pug/model/matchup'
require 'tf2pug/model/team'
require 'tf2pug/model/server'

class Match
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :map
  belongs_to :server
  
  property :pug, Boolean, :default => true
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  is :state_machine, :initial => :setup, :column => :state do
    state :setup,      :enter => :setup_match
    state :scheduling
    state :warmup,     :enter => :start_match
    state :live
    state :final,      :enter => :end_match
    
    event :forward do
      transition :from => :setup,      :to => :scheduling
      transition :from => :scheduling, :to => :warmup
      transition :from => :warmup,     :to => :live
      transition :from => :live,       :to => :final
    end
  end
  
  has n, :signups,  :constraint => :destroy
  has 2, :matchups, :constraint => :destroy
  has 2, :teams,    :through => :matchups
  
  def home; matchups.first(:home => true); end
  def away; matchups.first(:home => false); end
  
  def setup_match
    server = Server.first(:order => :played_at.asc)
    map = Map.random
    
    update(:map => map, :server => server)
  end
  
  def start_match
    @server.start(@map) # if an exception is thrown, the state never gets updated
  end
  
  def end_match
  
  end
end
