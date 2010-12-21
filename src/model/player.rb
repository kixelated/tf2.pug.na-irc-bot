require_relative '../database'

class Player < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  belongs_to :user
  
  has_many :stats
end
