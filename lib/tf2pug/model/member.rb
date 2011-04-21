require 'tf2pug/database'
require 'tf2pug/model/team'
require 'tf2pug/model/user'

class Member
  include DataMapper::Resource
  
  belongs_to :team, :key => true
  belongs_to :user, :key => true
  
  is :list, :scope => :team_id
end

module MemberOperations
  def leader; self.members.get(0); end
  
  def add_member(user, leader = true)
    temp = self.members.create(:user => user)
    temp.move(0) if leader # user wants leader
  end

  def remove_member(user)
    self.members.destroy(:user => user)
  end
end
