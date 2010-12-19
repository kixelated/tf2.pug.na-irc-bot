require '../database.rb'

class Stat < ActiveRecord::Base
  belongs_to :player
  
  validates :class, :presence => true
end
