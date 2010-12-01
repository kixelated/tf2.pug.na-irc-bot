class Quitter
  include Cinch::Plugin

  match /quit/, method: :quit
  
  def quit m
    m.bot.quit if m.user.opped?
  end
end