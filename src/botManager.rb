require 'singleton'
require_relative 'constants'

class BotManager
  include Singleton
  include Constants
  
  def initialize
    @bots = []
    @queue = []
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def quit
    @bots.each { |bot| bot.quit }
    @bots.clear
  end

  def msg recipient, message, notice = false
    @queue << { :to => recipient, :message => message, :notice => notice }
  end
  
  def notice to, message
    msg to, message, true
  end
  
  def start
    while @bots.size > 0
      unless @queue.empty?
        tosend = @queue.shift
        bot = @bots.push(@bots.shift).last
        
        bot.msg tosend[:to], tosend[:message], tosend[:notice]
        
        sleep(1.0 / (const["messengers"]["mps"].to_f * @bots.size.to_f))
      else
        sleep(const["delays"]["manager"].to_f)
      end
    end
  end
end
