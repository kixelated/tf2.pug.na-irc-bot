require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/map'
require 'tf2pug/model/match'
require 'tf2pug/model/server'
require 'tf2pug/model/signup'
require 'tf2pug/model/pick'

class Pug < Match
  is :state_machine, :initial => :waiting, :column => :state_pug do
    state :waiting
    state :afk
    state :picking
    state :final
    
    event :advance_pug do
      transition :from => :waiting, :to => :afk
      transition :from => :afk,     :to => :picking
      transition :from => :picking, :to => :final
    end
  end
  
  has n, :signups
  has n, :picks
  
  include SignupOperations
  include PickOperations
  
  class << self
    def waiting
      # try finding a waiting pug, otherwise, create one (there should always be a waiting pug)
      Pug.first(:state_pug => :waiting) || Pug.create(:server => Server.last_played, :map => Map.random, :teams => Team.random(2))
    end
    
    def picking
      Pug.first(:state_pug => :picking)
    end
  end
end
