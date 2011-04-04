require 'tf2pug/database'

class Team
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String, :index => true, :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matchups
  has n, :matches,  :through => :matchups
  has n, :rosters,  :constraint => :destroy
  has n, :users,    :through => :rosters
  
  def add(user, leader = true)
    temp = rosters.create(:user => user)

    if temp and leader # operation was successful and user wants leader
      rosters.first(:leader => true).update(:leader => false)
      temp.update(:leader => true)
    end
  end

  def remove(user)
    temp = rosters.first(:user => user)
    return unless temp
    
    # select a random new leader if deleting the current one
    rosters.first(:leader => false).update(:leader => true) if temp.leader

    temp.destroy
  end
end
