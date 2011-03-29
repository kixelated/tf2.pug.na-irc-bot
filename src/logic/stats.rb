require_relative '../database'
require_relative '../bot/irc'
require_relative '../models/user'

module StatsLogic
  def self.calculate_total user
    user.picks.count
  end
  
  def self.calculate_fatkid user
    temp = user.picks.aggregate(:all.count, :tfclass.count)
    temp[1].to_f / temp[0].to_f
  end
  
  def self.calculate_ratios user
    total = user.stats.count
    temp = user.stats.group(:tfclass).all.collect { |stat| [stat.tfclass, stat.count.to_f / total.to_f] }
    Hash[temp]
  end

  def self.list_stats player
    user = UserLogic::find_user player
    return message "There are no records of the user #{ player.nick }" unless user
    
    total = calculate_total(user)
    output = calculate_ratios(user).collect { |tfclass, percent| "#{ (percent * 100).round }% #{ tfclass.name }" }

    message "#{ user.nick }#{ "*" unless user.auth } has #{ total } games played: #{ output * ", " }"
  end
end
