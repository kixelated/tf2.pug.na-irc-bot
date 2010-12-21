require_relative '../database'

class Match < ActiveRecord::Base
  has_and_belongs_to_many :teams # TODO: Create join table.
    
  has_many :players
  has_many :users, :through => :players
  has_many :stats, :through => :players
end
