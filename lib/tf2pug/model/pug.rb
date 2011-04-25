require 'tf2pug/database'
require 'tf2pug/model/map'
require 'tf2pug/model/match'
require 'tf2pug/model/pick'
require 'tf2pug/model/server'
require 'tf2pug/model/signup'
require 'tf2pug/model/team'

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
  
  has n, :signups, :constraint => :destroy
  has n, :picks,   :constraint => :destroy
  
  def signup_add(user, tfclasses)
    raise "User is restricted." if user.restricted?
    
    self.signup_remove(user)
    
    tfclasses.each do |tfclass| 
      self.signups.create(:user => user, :tfclass => tfclass)
    end
  end
  
  def signup_remove(user)
    self.signups.all(:user => user).destroy
  end
  
  def signup_replace(user_old, user_new)
    self.signup_remove(user_new)
    self.signups.all(:user => user_old).update(:user => user_new)
  end
  
  def signup_clear
    self.signups.all.destroy
  end
  
  def signup_map(&block)
    Hash.new.tap do |output|
      self.signups.each do |signup|
        (output[block.call(signup)] ||= []) << signup
      end
      output.default = []
    end
  end
  
  def signup_classes
    self.signup_map { |signup| signup.tfclass }
  end

  def signup_users
    self.signup_map { |signup| signup.user }
  end
  
  def choose_captains
    tfcaptain = Tfclass.first(:name => "captain") # captain is a hard-coded class
    captains = self.signups.all(:tfclass => tfcaptain).shuffle.first(2)
    
    self.teams.zip(captains).each do |team, captain|
      self.picks.create(:team => team, :user => captain, :tfclass => tfcaptain)
    end
  end
  
  class << self
    def create_random
      self.create(:server => Server.last_played, :map => Map.random, :teams => Team.all(:pug => true).shuffle.first(2))
    end
  
    def waiting; self.first(:state_pug => :waiting); end
    def picking; self.first(:state_pug => :picking); end
  end
end
