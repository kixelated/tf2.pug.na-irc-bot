require 'cinch'

require './pug.rb'
require './quitter.rb'
require './masterMessenger.rb'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "IRCCompanionBot"
    c.server = "irc.gamesurge.net"
    c.plugins.plugins = [ Pug, Quitter ]
    c.channels = [ "#tf2.pug.na.beta" ]
    c.verbose = true
  end
end

bot.start