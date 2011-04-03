require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/model/match'

class Pug < Match
  include DataMapper::Resource
  
  is :state_machine, :initial => :waiting, :column => :state_pug do
    state :waiting,
    state :afk,
    state :picking,
    state :final
    
    event :forward_pug do
      transition :from => :waiting, :to => :afk
      transition :from => :afk,     :to => :picking
      transition :from => :picking, :to => :final
    end
  end
  
  has n, :signups, :constraint => :destroy
  
  def add(user, tfclasses)
    return unless can_add?
    
    remove(user) # delete any previous signups
    signups.create(:user => user, :tfclasses => tfclasses) # create the signups
  end
  
  def remove(user)
    return unless can_remove?
  
    pug.signups.all(:user => user).destroy # delete any previous signups
  end
  
  def replace(user_old, user_new)
    return unless can_add? and can_remove?
  
    signups.all(:user => user_old).update(:user => user_new)
  end
  
  def can_add?
    @state_pug == :setup
  end
  
  def can_remove?
    @state_pug == :setup
  end
end
