require 'singleton'
require_relative 'constants'

class BotManager
  include Singleton
  
  def initialize
    @bots = []
    @queue = []
  end
  
  def add(bot, *channels)
    @bots << bot

    @channels ||= Hash.new
    channels.each do |channel|
      @channels[channel] ||= Array.new
      @channels[channel] << bot
    end
  end
  
  def quit
    @bots.each { |bot| bot.quit }
    @bots.clear
    @channels.clear
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

        if @channels[tosend[:to]]
          bots = @channels[tosend[:to]]
        else
          bots = @bots
        end

        bot = bots.push(bots.shift).last
        
        bot.msg tosend[:to], tosend[:message], tosend[:notice]
        
        sleep(1.0 / (Constants.const["messengers"]["mps"].to_f * @bots.size.to_f))
      else
        sleep(Constants.const["delays"]["manager"].to_f)
      end
    end
  end
end
