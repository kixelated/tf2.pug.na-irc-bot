require 'cinch'

require_relative '../constants'
require_relative 'botManager'

class BotMessenger < Cinch::Bot
  include Constants

  def initialize i
    super()
    
    configure do |c|
      c.server = Constants.Constants.irc['server']
      c.port = Constants.Constants.irc['port']
      c.nick = Constants.Constants.messengers['nick'] + i.to_s
      c.local_host = Constants.Constants.internet['local_host']
      
      c.channels = [ Constants.Constants.irc['channel'] ] 
      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.Constants.irc['auth_serv'], "AUTH #{ Constants.Constants.irc['auth'] } #{ Constants.Constants.irc['auth_password'] }" if Constants.Constants.irc['auth']
    end
    
    BotManager.instance.add self
  end
end

