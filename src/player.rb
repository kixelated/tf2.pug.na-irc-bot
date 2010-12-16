require './database.rb'

class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams
end
