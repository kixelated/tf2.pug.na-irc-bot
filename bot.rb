require 'cinch'
require './pug.rb'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "PugBotBeta"
    c.server = "irc.gamesurge.net"
    c.plugins.plugins = [Pug]
    c.channels = ["#tf2.pug.na.beta"]
  end
  
  # !quit
  on :message, /quit/ do |m|
    bot.quit
  end
end

bot.start