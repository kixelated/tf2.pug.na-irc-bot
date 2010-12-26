require_relative '../database'

require_relative 'player'
require_relative 'tfclass'

class Stat < ActiveRecord::Base
  belongs_to :player
  belongs_to :tfclass
end
