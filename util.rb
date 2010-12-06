require 'open-uri'

module Utilities
  def make_title msg, fore = 0, back = 1
    colourize msg.rjust(15), fore, back
  end

  def colour_start fore = 0, back = 1
    "\x03#{ fore.to_s.rjust(2, "0") },#{ back.to_s.rjust(2, "0") }"
  end
  
  def colour_end
    "\x03"
  end

  def colourize msg, fore = 0, back = 1
    colour_end + colour_start(fore, back) + msg + colour_end + colour_start(0)
  end
  
  def isvalidsteamid? steamid
    steamid =~ /^STEAM_0:[01]:[0-9]{7,8}$/
  end
  
  def isvalidprofileurl? url
    url =~ /^(http:\/\/)?(www.)?steamcommunity.com\/id\/.*\/?$/
  end
  
  def get_steam_profile_url steamid
    return "" unless isvalidsteamid? steamid
    id = steamid.split(":") 
    "http://steamcommunity.com/id/#{ (id[2] * 2) + 76561197960265728 + id[1] }"
  end
  
  def profilecontainscode? profileurl, code
    file = open(profileurl)
    content = file.read
    content.include?(code)
  end
  
end

class Hash
  def collect
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = yield k, v
      end
    end
  end
  
  def collect!
    self.each do |k, v|
      self[k] = yield k, v
    end
  end

  # Proper invert, values are not always unique.
  # Input: a => b, c => b, d => e
  # Output: b => [a, c], e => [d]
  def invert_proper
    self.class.new.tap do |hash|
      self.each do |k, v|
        (hash[v] ||= []) << k
      end
    end
  end
  
  # Input: a => [b, c], d => [e] 
  # Output: b => [a], c => [a], e => [d]
  def invert_proper_arr
    self.class.new.tap do |hash|
      self.each do |k, v|
        v.each do |w| 
          (hash[w] ||= []) << k
        end
      end
    end
  end
end