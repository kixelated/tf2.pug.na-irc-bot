require 'summer'

require './variables.rb'
require './botManager.rb'

class BotMessenger < Summer::Connection
  def initialize num = 0
    super Const::Irc_server, Const::Irc_port, "#{ Const::Nick_messenger }#{ num }", Const::Irc_channel, Const::Irc_vhost

    BotManager.instance.add self
  end
end

