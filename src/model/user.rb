require '../database.rb'

class User < ActiveRecord::Base
  has_and_belongs_to_many :teams # TODO: Create join table.
  
  has_many :players
  has_many :stats, :through => :players
  
  validates :name, :presence => true
end
