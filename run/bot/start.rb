require_relative '../config.rb'

require 'tf2pug/constants'
require 'tf2pug/database'
require 'tf2pug/bot/master'
require 'tf2pug/bot/messenger'
require 'tf2pug/bot/manager'

DataMapper.finalize

bots = [ BotMaster.new ]
Constants.messengers['count'].times { |i| bots << BotMessenger.new(i) }

threads = []
bots.each do |bot|
  BotManager.instance.add(bot)
  threads << Thread.new(bot) { |bot| bot.start }
end

threads[0].join # join on master, so messagers will also quit on crash
