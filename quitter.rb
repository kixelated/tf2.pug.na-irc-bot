class Quitter
  include Cinch::Plugin

  match /quit/, method: :quit
  
  def quit m
    m.bot.quit if m.channel.opped? m.user
  end
end