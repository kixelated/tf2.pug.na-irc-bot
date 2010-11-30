require './util.rb'

class Team
  include Utilities

  attr_accessor: :captain, :players
	attr_accessor: :name, :colour
  
  # constants
  max_size = 6
  minimum = { "scout" => 2, "soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 }

	def initialize captain, name, colour
    @captain = captain
		@players = { @captain => "captain" }
    
    @name = name
    @colour = colour
	end
  
  def add user, clss
    @players[user] = clss
  end
  
  def remaining_classes
    temp = @players.invert_proper.collect { |clss| clss.size }
    (Team::minimum - temp).reject { |x| x < 0 } 
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
