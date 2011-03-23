require_relative '../database'

require_relative 'match'

class Server
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  property :host, String
  property :port, Integer
  property :pass, String
  property :rcon, String
  
  has n, :matches
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
