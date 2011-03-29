require 'cinch'

require_relative '../constants'
require_relative 'botManager'

class BotMessenger < Cinch::Bot
  include Constants

  def initialize i
    super()
    
    configure do |c|
      c.server = Constants.irc['server']
      c.port = Constants.irc['port']
      c.nick = Constants.messengers['nick'] + i.to_s
      c.local_host = Constants.internet['local_host']
      
      c.channels = [ Constants.irc['channel'] ] 
      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.irc['auth_serv'], "AUTH #{ Constants.irc['auth'] } #{ Constants.irc['auth_password'] }" if Constants.irc['auth']
    end
    
    BotManager.instance.add self
  end
end

