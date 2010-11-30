class Team
  attr_accessor: :captain, :players
	attr_accessor: :name, :colour
  
  # constants
  size = 6
  classes = { "scout" => 2, "soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 }

	def initialize captain
    @captain = captain
		@players = { @captain => "captain" }
	end
  
  def add_player user
    @players << user
  end
	
	def to_s
    temp = []
    @players.each { |k, v| temp << "#{ k } => #{ v.to_s }" }
    "#{ @name.capitalize } team: #{ temp.join(", ") }"
  end
end
