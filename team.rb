require './util.rb'

class Team
  include Utilities

  attr_accessor :captain, :players
	attr_accessor :name, :colour
  
  # constants
  Max_size = 6
  Minimum = { "scout" => 2, "soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 }

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
    players.each do |k, v|
      (output ||= []) << "#{ k } as #{ my_colourize v }"
    end
  
    "#{ my_colourize @name }: #{ output.join(", ") if output }"
  end
end
