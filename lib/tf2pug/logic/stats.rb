require 'tf2pug/database'
require 'tf2pug/bot/irc'
require 'tf2pug/model/user'

module Logic
  module Stats
    def self.list_stats(player)
      user = User.find_player player
      return Irc.message "There are no records of the user #{ player }" unless user
      
      total = user.picks.count(:tfclass)
      output = user.picks.all(:tfclass).group(:tfclass).collect { |pick| "#{ (pick.count.to_f / total.to_f * 100).round }% #{ pick.tfclass.name }" }

      Irc.message "#{ user.nick }#{ "*" unless user.auth } has #{ total } games played: #{ output * ", " }"
    end
  end
end
