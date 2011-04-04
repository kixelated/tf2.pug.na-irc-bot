require_relative '../config'
require_relative '../fakebot'

require 'tf2pug/database'
require 'tf2pug/logic/signup'

DataMapper.finalize

players = [
  [ "pingu", "pingu" ],
  [ "noauth", nil ],
  [ "pingu", nil ],
  [ "random", "rdahfdo" ]
]

players.collect! do |player|
  UserFake.new(*player)
end

players.each do |player|
  classes = Tfclass.all(:pug.gte => 1).select { |clss| rand(nil) > 0.5 }
  classes.collect! { |clss| clss.name }
  
  puts "#{ player.nick } added as #{ classes * ", " }"

  SignupLogic.add_signup player, classes
  SignupLogic.list_signups
  SignupLogic.list_classes_needed
end

players.each do |player|
  SignupLogic.remove_signup player
  SignupLogic.list_signups
  SignupLogic.list_classes_needed
end
