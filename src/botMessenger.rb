require_relative 'summer'
require_relative 'constants'
require_relative 'botManager'

class BotMessenger < Summer::Connection
  def initialize num = 0
    super(
      Constants.const["irc"]["server"], 
      Constants.const["irc"]["port"], 
      "#{ Constants.const["messengers"]["nick"] }#{ num }", 
      Constants.const["irc"]["channel"], 
      Constants.const["irc"]["local_host"]
    )

    BotManager.instance.add self
  end
end

