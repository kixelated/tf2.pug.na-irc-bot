require 'tf2pug/database'
require 'tf2pug/bot/irc'
require 'tf2pug/logic/user'
require 'tf2pug/models/user'

module StatsLogic
  def self.list_stats player
    user = User.find_user player
    return message "There are no records of the user #{ player }" unless user
    
    total = user.picks.count(:tfclass)
    output = user.picks.all(:tfclass).group(:tfclass).collect { |pick| "#{ (pick.count.to_f / total.to_f * 100).round }% #{ pick.tfclass.name }" }

    message "#{ user.nick }#{ "*" unless user.auth } has #{ total } games played: #{ output * ", " }"
  end
end
