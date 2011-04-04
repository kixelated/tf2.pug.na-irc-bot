require_relative '../config'

require 'tf2pug/database'
require 'tf2pug/model/map'

DataMapper.finalize

# This file verifies that Map.random is working as expected

trials = 1000
count = {}

trials.times do |i| 
  map = Map.random
  map.played_at = Time.now
  
  count[map.name] ||= 0
  count[map.name] += 1
end

sum = Map.all.sum(:weight)
Map.all.each do |map|
  puts "#{ map.name }: expected #{ (trials * map.weight / sum).to_i }, actual #{ count[map.name] or 0 }"
end
