require 'cinch'

require 'tf2pug/constants'
require 'tf2pug/bot/manager'

class BotMessenger < Cinch::Bot
  def initialize(i)
    super() # need the ()
    
    configure do |c|
      c.server = Constants.irc['server']
      c.port = Constants.irc['port']
      c.nick = Constants.messengers['nick'] + i.to_s
      c.local_host = Constants.internet['local_host']
      
      c.channels = [ Constants.irc['channel'] ] 
      c.verbose = false
    end
    
    on(:connect) do 
      bot.msg Constants.irc['auth_serv'], "AUTH #{ Constants.irc['auth'] } #{ Constants.irc['auth_password'] }" if Constants.irc['auth']
    end
  end
end

