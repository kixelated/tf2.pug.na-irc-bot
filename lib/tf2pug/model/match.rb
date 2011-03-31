require 'tf2pug/constants'
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
    state :setup
    state :picking
    state :warmup,  :enter => :start_match
    state :live
    state :final,   :enter => :end_match
    
    event :forward do
      transition :from => :setup,   :to => :picking
      transition :from => :picking, :to => :warmup
      transition :from => :warmup,  :to => :live
      transition :from => :live,    :to => :final
    end
  end
  
  # TODO: Check syntax
  before :save, :on => :create, :method => :setup_match
  
  has n, :signups,  :constraint => :destroy
  has 2, :matchups, :constraint => :destroy
  has 2, :teams,    :through => :matchups
  
  class << self
    def self.create_pug
      match = self.create(:pug => true)

      # Select 2 random pug team names
      Constants.teams.shuffle.first(2).each_with_index do |team_name, i|
        team = Team.first_or_create(:name => team_name)
        match.matchups.create(:team => team, :home => (i == 0))
      end
    end
 
    def self.last_pug
      self.last(:pug => true)
    end
  end
  
  def home; matchups.first(:home => true); end
  def away; matchups.first(:home => false); end
  
  def setup_match do
    @server = Server.first(:order => :played_at.asc)
    @map = Map.random
  end
  
  def start_match
    @server.start(@map) # if an exception is thrown, the state never gets updated
  end
  
  def end_match
    # TODO
  end
  
  def can_add?
    @state == :setup
  end
  
  def can_remove?
    @state == :setup
  end
end
