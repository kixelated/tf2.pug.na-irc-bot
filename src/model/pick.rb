require_relative '../database'

require_relative 'matchup'
require_relative 'user'
require_relative 'tfclass'

class Pick
  include DataMapper::Resource
  
  belongs_to :matchup, :key => true
  belongs_to :user,    :key => true
  belongs_to :tfclass
end
