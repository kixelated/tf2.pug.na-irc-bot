require 'cinch'
require 'summer'

require './variables.rb'

require './pug.rb'
require './quitter.rb'
require './masterMessenger.rb'

mainbot = Thread.new do
  bot = Cinch::Bot.new do
    configure do |c|
      c.server = Const::Irc_server
      c.port = Const::Irc_port
      c.vhost = Const::Irc_vhost
      c.nick = Const::Nick_bot
      c.channels = [ Const::Irc_channel ]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = true
    end
  end
  
  MasterMessenger.instance.add bot
  bot.start
end

Const::Messenger_count.times do |i|
  sleep(10)

  Thread.new do
    bot = Summer::Connection.new(Const::Irc_server, Const::Irc_port, "#{ Const::Nick_messenger }#{ i }", Const::Irc_channel, Const::Irc_vhost)
      
    MasterMessenger.instance.add bot
    bot.start
  end
end

mainbot.join