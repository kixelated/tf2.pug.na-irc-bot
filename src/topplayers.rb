require_relative 'model/player.rb'

Player.find(:all, :select => "*, count(*) AS count, user_id", :group => "user_id", :order => "count DESC").each do |player|
  puts "#{ player.count.to_s.rjust(3) } - #{ player.user.name }"
end
