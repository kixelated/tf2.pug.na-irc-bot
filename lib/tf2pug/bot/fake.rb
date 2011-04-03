class BotFake
  def message(target, msg, notice = false)
    puts "#{ "(notice) " if notice }#{ target }: #{ msg }"
  end
  
  def quit
    true
  end
end

