#require 'open-uri'

module Utilities  
  def rjust msg, justify = const["formatting"]["justify"]
    msg.to_s.rjust(justify)
  end

  def colour_start fore, back = 0
    "\x03#{ fore.to_s.rjust(2, "0") }" + "#{ ",#{ back.to_s.rjust(2, "0") }" if back != 0 }"
  end
  
  def colour_end
    "\x03"
  end
  
  def colourize msg, fore = const["colours"]["white"], back = const["colours"]["black"]
    output = msg.to_s.gsub(/\x03\d.*?\x03/) { |str| "#{ colour_end }#{ str }#{ colour_start(fore, back) }" }
    "#{ colour_start(fore, back) }#{ output }#{ colour_end }"
  end
  
  def bold msg
    "\x02#{ msg.to_s }\x02"
  end
=begin
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
=end
end

class Hash
  # Proper collect, which returns a hash with just values changed.
  # Input: { a => 1, b => 2}
  # Block: { |i| i + 2 }
  # Output: { a => 3, b => 4 }
  # Output (non-proper): [3, 4]
  def collect_proper
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = yield k, v
      end
    end
  end
  
  def collect_proper!
    self.each do |k, v|
      self[k] = yield k, v
    end
  end

  # Proper invert, values are not always unique.
  # Input: { a => b, c => b, d => e }
  # Output: { b => [a, c], e => [d] }
  # Output (non-proper): { b => a, e => d }
  def invert_proper
    self.class.new.tap do |hash|
      self.each do |k, v|
        (hash[v] ||= []) << k
      end
      hash.default = []
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
      hash.default = []
    end
  end
  
  # Input: a => [b, c], d => [e] 
  # Arg: a => [f]
  # Output: a => [b, c, f], d => [e]
  def merge_proper other
    self.dup.tap do |hash|
      other.each do |k, v|
        hash[k] = (hash[k] || []) + v
      end
    end
  end
  
  def merge_proper_array other
    self.dup.tap do |hash|
      other.each do |k, v|
        v.each do |w|
          hash[k] = (hash[k] || []) + w
        end
      end
    end
  end
end
