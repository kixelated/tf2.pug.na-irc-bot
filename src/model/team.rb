require_relative '../constants'
require_relative '../database'
require_relative '../util'

class Team < ActiveRecord::Base
  include Constants

  has_and_belongs_to_many :matches # TODO: Create join table.
  has_and_belongs_to_many :users # TODO: Create join table.
  
  has_many :players
  has_many :stats, :though => :players
  has_many :matches, :though => :players

  attr_accessor :captain, :colour, :signups
  
  validates :name, :presence => true
  validates :captain, :presence => true
  
  def colourize str, bg = const["colours"]["black"]
    Utilities::colourize str, @colour, bg
  end
  
  def get_classes
    @signups.invert_proper
  end
  
  def formatted
  
  end
end
