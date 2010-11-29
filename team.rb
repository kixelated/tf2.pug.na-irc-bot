class Team
	attr_accessor: :name, :captain, :players
  
	def initialize name, captain
    @name = name
    @captain = captain
		@players = { @captain => "captain" }
	end
	
	def to_s
    temp = []
    @players.each { |k, v| temp << "#{ k } => #{ v.to_s }" }
    "#{ @name.capitalize } team: #{ temp.join(", ") }"
  end
end
