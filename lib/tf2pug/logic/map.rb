require 'tf2pug/bot/irc'
require 'tf2pug/model/map'
require 'tf2pug/model/pug'

module MapLogic
  def self.list_map
    pug = Pug.last
    Irc.message "The current map is #{ pug.map.name }"
  end
  
  def self.list_rotation
    output = Map.all.collect { |map| "#{ map.name }(#{ map.weight })" }
    Irc.message "Map(weight) rotation: #{ output * ", " }"
  end
end
