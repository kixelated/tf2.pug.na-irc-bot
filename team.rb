class Team
	attr_accessor: :captain
	def initialize
		@players = Array.new
		@classes = Array.new
		@captain
		@classes_count = { "scout" => 4, #"soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 
		}
	end
	
	def add_player player, clss
		@players << player
		@classes << clss
		@classes_count[clss] -= 1
	end

	def print_teams
	
	end
	
end
