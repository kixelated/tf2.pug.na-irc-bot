require 'tf2pug/model/map'
require 'tf2pug/model/match'

module MapLogic
  def list_map
    match = Match.last_pug
    message "The current map is #{ match.map.name }"
  end
  
  def self.list_rotation
    output = Map.all.collect { |map| "#{ map.name }(#{ map.weight })" }
    message "Map(weight) rotation: #{ output * ", " }"
  end
end
