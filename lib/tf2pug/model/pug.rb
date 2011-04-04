require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/match'

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
  
  has n, :signups, :constraint => :destroy
  has n, :picks,   :constraint => :destroy
  
  def add_signup(user, tfclasses)
    return unless can_add?
    
    remove_signup(user) # delete any previous signups
    self.signups.create(:user => user, :tfclasses => tfclasses) # create the signups
  end
  
  def remove_signup(user)
    return unless can_remove?
  
    self.signups.all(:user => user).destroy # delete any previous signups
  end
  
  def replace_signup(user_old, user_new)
    return unless can_add? and can_remove?
  
    self.signups.all(:user => user_old).update(:user => user_new)
  end
  
  def add_pick(user, team, tfclass)
    self.picks.create(:user => user, :team => team, :tfclass => tfclass)
  end
  
  def pick_num
    self.picks.count
  end
  
  def can_add?
    @state_pug == :setup
  end
  
  def can_remove?
    @state_pug == :setup
  end
end
