require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/models/match'

module MatchLogic
  def self.create_pug
    match = Match.create(:pug => true)

    # Select 2 random pug team names
    Constants.teams.shuffle.first(2).each_with_index do |team_name, i|
      team = Team.first_or_create(:name => team_name)
      match.matchups.create(:team => team, :home => (i == 0))
    end
  end

  def self.last_pug
    Match.last(:pug => true)
  end
end
