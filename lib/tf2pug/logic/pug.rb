require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/team'
require 'tf2pug/model/tfclass'

module PugLogic
  def self.create_pug
    map = Map.random
    server = Server.first(:order => :played_at.asc)
    teams = choose_teams
  
    Pug.create(:server => server, :map => map, :teams => teams)
  end
  
  def create_captains(pug)
    tfcaptain = Tfclass.first(:name => "captain") # captain is a hard-coded class
    captains = choose_captains(pug, tfcaptain)
    
    output = captains.collect do |user| 
      Irc.notice user.nick, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command. Remember, you will play the class that you do not pick, so be careful with your last pick."
      user.nick
    end
    
    Irc.message "Captains are #{ output * ", " }"
  end
  
  def self.choose_teams
    Constants.teams.shuffle.first(2).collect do |team_name|
      Team.first_or_create(:name => team_name)
    end
  end
  
  def self.choose_captains(pug, tfclass)
    captains = pug.signups.all(:tfclass => tfclass).sort_by do |signup|
      temp = signup.user.picks.aggregate(:all, :team)
      temp[0].to_f / temp[1].to_f # sort by fatkid ratio
    end
    
    captains.last(2).shuffle
  end
end
