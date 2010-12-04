class Quitter
  include Cinch::Plugin

  match /quit/, method: :quit
  
  def quit m
    MasterMessenger.instance.quitall! if m.channel.opped? m.user
  end
end