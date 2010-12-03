require 'singleton'

class MasterMessenger
  include Singleton
  
  def initialize
    @bots = []
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def select
    @bots.push(@bots.shift).first
  end
  
  def msg channel, msg
    select.msg channel, msg
  end
  
  def notice channel, msg
    select.notice channel, msg
  end
end