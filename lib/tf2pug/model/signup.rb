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
  
  def tfclass_signups(tfclass)
    self.signups.all(:tfclass => tfclass)
  end
  
  def list_signups(tfclasses = Tfclass.all)
    Hash.new.tap do |output|
      self.signups.all(:tfclass => tfclasses).each do |signup|
        (output[signup.tfclass] ||= []) << signup
      end
    end
  end
  
  def count_signups
    self.signups.all(:fields => [:user_id], :unique => true).size
  end
  
  def clear_signups
    self.signups.delete
  end
end
