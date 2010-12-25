require_relative '../database'

require_relative 'team'
require_relative 'match'
require_relative 'user'
require_relative 'stat'

class Player < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  belongs_to :user
  
  has_many :stats
end
