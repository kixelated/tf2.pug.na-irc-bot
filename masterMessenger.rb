require 'singleton'

class MasterMessenger
  include Singleton
  
  def initialize
    @bots = []
  end
  
  def add bot
    @bots << bot unless @bots.includes? bot
  end
  
  def select
    @bots.push @bots.shift
  end
  
  def message channel, msg
    select.message channel, msg
  end
  
  def notice channel, msg
    select.notice channel, msg
  end
end