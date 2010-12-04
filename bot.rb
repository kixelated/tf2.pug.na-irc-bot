require 'rubygems'

require 'cinch'
require 'summer'

require './pug.rb'
require './quitter.rb'
require './masterMessenger.rb'

mainbot = Thread.new do
  bot = Cinch::Bot.new do
    configure do |c|
      c.nick = "#{Variables::Bot_Nick}1"
      c.server = "irc.gamesurge.net"
      c.plugins.plugins = [ Pug, Quitter ]
      c.channels = [ Variables::Main_Channel ]
      c.verbose = true
    end
  end

  MasterMessenger.instance.add bot
  bot.start
end

Variables::Messenger_count.times do |i|
  sleep(30)

  Thread.new do
    bot = Summer::Connection.new("irc.gamesurge.net", 6667, "#{Variables::Bot_Nick}#{i + 2}", Variables::Main_Channel)
      
    MasterMessenger.instance.add bot
    bot.start
  end
end

MasterMessenger.instance.processqueue!

mainbot.join