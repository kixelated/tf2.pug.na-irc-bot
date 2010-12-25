require_relative '../database'

require_relative 'player'
require_relative 'stat'

class User < ActiveRecord::Base
  has_and_belongs_to_many :teams
  
  has_many :players
  has_many :stats, :through => :players
end
