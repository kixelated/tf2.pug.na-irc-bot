require 'bundler/setup'

$:.push('../lib')

require 'tf2pug/database'
require 'tf2pug/constants'
require 'tf2pug/bot/master'
require 'tf2pug/bot/messenger'
require 'tf2pug/bot/manager'

DataMapper.finalize

bots = [ BotMaster.new ]
Constants.messengers['count'].times { |i| bots << BotMessenger.new(i) }

bots.each do |bot|
  Thread.new { bot.start }
  sleep(Constants.delay['bot'])
end

BotManager.instance.start
