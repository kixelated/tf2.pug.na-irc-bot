require 'bundler/setup'

Dir['tf2pug/model/*'].each { |file| require file }

DataMapper.finalize
DataMapper.auto_upgrade!
