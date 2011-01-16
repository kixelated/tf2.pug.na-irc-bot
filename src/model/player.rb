require_relative '../database'

require_relative 'team'
require_relative 'match'
require_relative 'user'
require_relative 'pick'
require_relative 'tfclass'

class Player < ActiveRecord::Base
  belongs_to :match
  belongs_to :team
  belongs_to :user
  
  has_many :picks
  has_and_belongs_to_many :signups, :class_name => "Tfclass", :join_table => "signups"
end
