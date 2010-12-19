require '../database.rb'

class Player < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  belongs_to :user
  
  has_many :stats
end
