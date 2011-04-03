require_relative '../config'

Dir['../../lib/tf2pug/model/*'].each { |file| require file }

DataMapper.finalize
DataMapper.auto_upgrade!
