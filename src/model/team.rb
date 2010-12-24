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
  
  def set_captain captain
    @captain = captain
    @signups = { captain => "captain" }
  end

  def set_details info
    @name = info["name"]
    @colour = info["colour"]
  end

  def my_colourize str, bg = const["colours"]["black"]
    colourize str, @colour, bg
  end
  
  def format_team
    output = @signups.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ format_name }: #{ output.join(", ") if output }"
  end
  
  def format_name
    my_colourize @name
  end
  
  def to_s
    @name
  end
end
