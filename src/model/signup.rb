require_relative '../database'

require_relative 'match'
require_relative 'user'
require_relative 'tfclass'

class Signup
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  belongs_to :user, :key => true
  belongs_to :tfclass, :key => true
end
