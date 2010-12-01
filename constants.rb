require './server.rb'
require './util.rb'

module Constants
  Afk_threshold = 60 * 10
  Afk_delay = 45
  Picking_delay = 45

  Team_count = 2
  Team_names = [ "Red team", "Blue team" ]
  Team_colours = [ 4, 10 ]
  
  Chicago1 = Server.new("chicago1.tf2pug.org", 27015, "tf2pug", "squid")
end
