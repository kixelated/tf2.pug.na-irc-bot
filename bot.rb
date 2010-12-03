require 'rubygems'

require 'cinch'
require 'summer'

require './pug.rb'
require './quitter.rb'
require './masterMessenger.rb'

mainbot = Thread.new do
  bot = Cinch::Bot.new do
    configure do |c|
      c.nick = "IRCCompanionBot"
      c.server = "irc.gamesurge.net"
      c.plugins.plugins = [ Pug, Quitter ]
      c.channels = [ "#tf2.pug.na.beta" ]
      c.verbose = true
    end
  end

  MasterMessenger.instance.add bot
  bot.start
end

2.times do |i|
  sleep(30)

  Thread.new do
    bot = Summer::Connection.new("irc.gamesurge.net", 6667, "IRCMessengerBot#{i}", "#tf2.pug.na.beta")
      
    MasterMessenger.instance.add bot
    bot.start
  end
end

mainbot.join