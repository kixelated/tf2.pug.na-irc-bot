require '../database.rb'

class Team < ActiveRecord::Base
  has_and_belongs_to_many :matches # TODO: Create join table.
  has_and_belongs_to_many :users # TODO: Create join table.
  
  has_many :players
  has_many :stats, :though => :players
  has_many :matches, :though => :players
  
  validates :name, :presence => true
end
