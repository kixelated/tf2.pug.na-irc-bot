require 'singleton'

require 'tf2pug/constants'

class BotManager
  include Singleton
  
  def initialize
    @bots = []
    @queue = []
  end
  
  def add(bot)
    @bots << bot unless @bots.include?(bot)
  end

  def message(target, msg, notice = false)
    @bots.push(@bots.shift).last.message(target, msg, notice)
  end
  
  def notice(target, message)
    message(target, message, true)
  end
  
  def quit
    @bots.each { |bot| bot.quit }
    @bots.clear
  end
end
