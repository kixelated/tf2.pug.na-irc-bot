require 'singleton'
require_relative 'constants'

class BotManager
  include Singleton
  include Constants
  
  def initialize
    @bots = []
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def quit
    @bots.each { |bot| bot.quit }
  end
  
  def select
    @bots.push(@bots.shift).first
  end
  
  def msg to, message
    select.msg to, message
    sleep 1.0 / const["messengers"]["mpstotal"]
  end
  
  def notice to, message
    select.notice to, message
    sleep 1.0 / const["messengers"]["mpstotal"]
  end
end
