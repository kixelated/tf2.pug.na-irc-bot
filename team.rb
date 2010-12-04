require './util.rb'

class Team
  include Utilities

  attr_accessor :captain, :players
	attr_accessor :name, :colour
  
  # constants
  Max_size = 2
  Minimum = { "scout" => 1, "soldier" => 1, "demo" => 0, "medic" => 0, "captain" => 1 }

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
    "#{ my_colourize @name }: #{ output.join(", ") if output }"
  end
end
