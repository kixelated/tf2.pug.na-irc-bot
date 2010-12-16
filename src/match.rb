require './database.rb'

class Match < ActiveRecord::Base
  belongs_to :home, :class_name => :team
  belongs_to :away, :class_name => :team
end
