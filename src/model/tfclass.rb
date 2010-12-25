require_relative '../database'

require_relative 'stat'

class Tfclass < ActiveRecord::Base
  belongs_to :stats
end
