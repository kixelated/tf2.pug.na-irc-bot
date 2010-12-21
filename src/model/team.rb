require_relative '../constants'
require_relative '../database'
require_relative '../util'

class Team < ActiveRecord::Base
  include Constants
  include Utilities

  has_and_belongs_to_many :matches # TODO: Create join table.
  has_and_belongs_to_many :users # TODO: Create join table.
  
  has_many :players
  has_many :stats, :through => :players
  has_many :matches, :through => :players

  attr_accessor :captain, :colour, :signups
  
  validates :name, :presence => true
  validates :captain, :presence => true
  
  def initialize *args
    super
    @signups = {}
  end
  
  def my_colourize str, bg = const["colours"]["black"]
    colourize str, @colour, bg
  end
  
  def get_classes
    @signups.invert_proper
  end
  
  def formatted
    output = @signups.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ my_colourize @name }: #{ output.values.join(", ") if output }"
  end
  
  def to_s
    @name
  end
end
