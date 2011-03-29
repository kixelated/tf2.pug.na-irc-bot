require_relative '../database'
require_relative '../models/user'
require_relative '../bot/irc'

module StatsLogic
  def self.calculate_total user
    user.players.sum(:team)
  end
  
  def self.calculate_fatkid user
    temp = user.players.aggregate(:all.count, :team.count)
    temp[1].to_f / temp[0].to_f
  end
  
  def self.calculate_ratios user, total
    user.stats.all.collect do |stat|
      stat.count.to_f / total.to_f
    end
  end

  def self.list_stats user
    u = find_user user
    return message "There are no records of the user #{ user.nick }" unless u
    
    total = calculate_total u
    output = calculate_ratios(u, total).collect { |stat, percent| "#{ (percent * 100).round }% #{ stat.tfclass }" }

    message "#{ u.name }#{ "*" unless u.auth } has #{ total } games played: #{ output * ", " }"
  end
end
