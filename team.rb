require './util.rb'

class Team
  include Utilities

  attr_accessor :captain, :players
	attr_accessor :name, :colour
  
  def initialize captain, name, colour
    @captain = captain
		@players = { captain => "captain" }
    
    @name = name
    @colour = colour
	end

  def get_classes
    @players.invert_proper
  end
  
  def my_colourize msg
    colourize msg, @colour
  end
  
  def to_s
    output = players.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ my_colourize @name }: #{ output.values.join(", ") if output }"
  end
end
