require 'bundler/setup'

$:.push('../../lib')

require 'tf2pug/database'
Dir['../../lib/tf2pug/model/*'].each { |file| require file }

DataMapper.finalize
DataMapper.auto_upgrade!
