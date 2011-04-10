require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/match'
require 'tf2pug/model/signup'
require 'tf2pug/model/pick'

class Pug < Match
  is :state_machine, :initial => :waiting, :column => :state_pug do
    state :waiting
    state :afk
    state :picking
    state :final
    
    event :forward_pug do
      transition :from => :waiting, :to => :afk
      transition :from => :afk,     :to => :picking
      transition :from => :picking, :to => :final
    end
  end
  
  has n, :signups
  has n, :picks,   :through => :matchups
  
  
  # Signup stuff
  def add_signup(user, tfclasses)
    remove_signup(user) # delete any previous signups
    
    tfclasses.each do |tfclass|
      self.signups.create(:user => user, :tfclass => tfclass) # create the signups
    end
  end
  
  def remove_signup(user)
    self.signups.all(:user => user).destroy # delete any previous signups
  end
  
  def replace_signup(user_old, user_new)
    self.signups.all(:user => user_old).update(:user => user_new)
  end
  
  # Picking stuff
  def num_pick
    self.picks.count
  end
end
