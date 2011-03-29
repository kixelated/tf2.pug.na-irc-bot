require_relative '../model/map'
require_relative '../model/server'

module StateLogic
  def create_match
    match = Match.create

    # Select 2 random pug team names
    Constants.teams.shuffle.first(2).each_with_index do |team_name, i|
      team = Team.first_or_create(:name => team_name)
      match.matchup.create(:team => team, :home => (i == 0))
    end
  end
  
  def finalize_match server, map
  
  end
end
