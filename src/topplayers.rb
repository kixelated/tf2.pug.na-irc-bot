require_relative 'model/player.rb'

match = Tfclass.first.signups.first.match_id
Player.select("COUNT(*) AS total, COUNT(team_id) AS picked, user_id, team_id").includes(:user).group(:user_id).where("match_id >= #{ match }").order("total DESC").each do |player|
  puts "#{ player.user.name } - #{ player.total } - #{ (100 * (player.total - player.picked).to_f / player.total.to_f).round(2) }%"
end
