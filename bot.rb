require 'rubygems'

require 'cinch'
require 'summer'

require './variables.rb'

require './pug.rb'
require './quitter.rb'
require './masterMessenger.rb'

mainbot = Thread.new do
  bot = Cinch::Bot.new do
    configure do |c|
      c.server = Variables::Irc_server
      c.port = Variables::Irc_port
      c.vhost = Variables::Irc_vhost
      c.nick = Variables::Nick_bot
      c.channels = [ Variables::Irc_channel ]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = false
    end
  end
  
  MasterMessenger.instance.add bot
  bot.start
end

Variables::Messenger_count.times do |i|
  sleep(30)

  Thread.new do
    bot = Summer::Connection.new(Variables::Irc_server, Variables::Irc_port, "#{ Variables::Nick_messenger }#{ i }", Variables::Irc_channel, Variables::Irc_vhost)
      
    MasterMessenger.instance.add bot
    bot.start
  end
end

mainbot.join