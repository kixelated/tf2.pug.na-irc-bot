require '../database.rb'

class Match < ActiveRecord::Base
  has_and_belongs_to_many :teams # TODO: Create join table.
    
  has_many :players
  has_many :users, :though => :players
  has_many :stats, :though => :players
end
