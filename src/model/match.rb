require_relative '../database'

require_relative 'team'
require_relative 'player'
require_relative 'user'
require_relative 'stat'

class Match < ActiveRecord::Base
  has_and_belongs_to_many :teams
    
  has_many :players
  has_many :users, :through => :players
  has_many :stats, :through => :players
end
