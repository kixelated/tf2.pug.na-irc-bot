require_relative '../database'

class Stat < ActiveRecord::Base
  belongs_to :player
  
  validates :class, :presence => true
end
