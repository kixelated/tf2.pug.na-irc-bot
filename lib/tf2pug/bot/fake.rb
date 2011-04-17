class BotFake
  def msg(target, msg, notice = false)
    puts "#{ "(notice) " if notice }#{ target }: #{ msg }"
  end
  
  def quit
    true
  end
end

class UserFake
  attr_accessor :nick, :authname
  
  def initialize nick, auth = nil
    @nick = nick; @authname = auth
  end
  
  def authed?; @authname != nil; end
  def refresh; end
end
