require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/models/pug'
require 'tf2pug/models/team'

module MatchLogic
  def self.create_pug
    pug = Pug.create

    # Select 2 random pug team names
    Constants.teams.shuffle.first(2).each_with_index do |team_name, i|
      team = Team.first_or_create(:name => team_name)
      pug.matchups.create(:team => team, :home => (i == 0))
    end
  end
end
