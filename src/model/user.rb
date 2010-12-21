require_relative '../database'

class User < ActiveRecord::Base
  has_and_belongs_to_many :teams
  
  has_many :players
  has_many :stats, :through => :players
  
  validates :name, :presence => true
  validates :auth, :presence => true
end
