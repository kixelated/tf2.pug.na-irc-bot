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
  
  def colourize msg
    colourize msg, @colour
  end
  
  def output_team
    output = players.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ my_colourize @name } Team: #{ output.values.join(", ") if output }"
  end

  def to_s
    colourize @name, @colour
  end
end
