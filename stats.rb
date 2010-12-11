require 'active_record'

class Stat < ActiveRecord::Base
  belongs_to :players
  belongs_to :matches
end