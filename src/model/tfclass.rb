require_relative '../database'

require_relative 'pick'
require_relative 'player'

class Tfclass < ActiveRecord::Base
  belongs_to :picks
  has_and_belongs_to_many :signups, :class_name => "Player", :join_table => "signups"
end
