require 'tf2pug/database'
require 'tf2pug/models/pug'
require 'tf2pug/models/team'
require 'tf2pug/models/tfclass'

module PugLogic
  def self.setup_pug
    pug = Pug.last(:state_pug => :picking)
    
    teams = choose_teams
    captains = choose_captains(pug)
    tfcaptain = Tfclass.first(:name => "captain") # captain is a hard-coded class
    
    teams.zip(captains).each do |team, captain|
      pug.matchups.create(:team => team)
      pug.picks.create(:user => captain, :team => team, :tfclass => tfcaptain)
      
      team.add_signup(captain, true) # add player to roster, and make them leader
    end
    
    output = captains.collect { |user| user.nick }
    Irc.message "Captains are #{ output * ", " }"
    
    captains.each do |user|
      Irc.notice user.nick, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command. Remember, you will play the class that you do not pick, so be careful with your last pick."
    end
  end
  
  def self.choose_teams
    Constants.teams.shuffle.first(2).collect do |team_name|
      Team.first_or_create(:name => team_name)
    end
  end
  
  def self.choose_captains(pug)
    captains = pug.signups.all(:tfclass => "captain").sort_by do |signup|
      temp = signup.user.picks.aggregate(:all, :team)
      temp[0].to_f / temp[1].to_f # sort by fatkid ratio
    end
    
    captains.last(2).shuffle
  end
end
