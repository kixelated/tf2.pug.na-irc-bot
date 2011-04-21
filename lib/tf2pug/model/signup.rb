require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Signup
  include DataMapper::Resource
  
  belongs_to :pug,       :key => true
  belongs_to :user,      :key => true
  has n,     :tfclasses, :key => true, :through => Resource
end

module SignupOperations
  def add_signup(user, tfclasses)
    remove_signup(user) # delete any previous signups
    self.signups.create(:user => user, :tfclasses => tfclasses)
  end
  
  def remove_signup(user)
    self.signups.all(:user => user).destroy # delete any previous signups
  end
  
  def replace_signup(user_old, user_new)
    self.signups.all(:user => user_old).update(:user => user_new)
  end
end
