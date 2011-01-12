require_relative '../database'

require_relative 'restriction'
require_relative 'player'
require_relative 'stat'

class User < ActiveRecord::Base
  has_and_belongs_to_many :teams
  
  has_one :restriction
  has_many :players
  has_many :stats, through: "players"
  
  validates :auth, uniqueness: { allow_nil: true }
  validates :name, presence: true, uniqueness: { scope: "auth" }
end
