require_relative '../constants'
require_relative '../database'

require_relative '../models/match'

module MatchLogic
  def create_pug
    match = Match.create(:pug => true)

    # Select 2 random pug team names
    Constants.teams.shuffle.first(2).each_with_index do |team_name, i|
      team = Team.first_or_create(:name => team_name)
      match.matchups.create(:team => team, :home => (i == 0))
    end
  end

  def last_pug
    pug = Match.last(:pug => true, :state => :waiting)
    pug = create_pug unless pug
    return pug
  end
end
