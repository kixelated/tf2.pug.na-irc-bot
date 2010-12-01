require './constants.rb'

module Utilities
  def make_title msg, colour = 1
    colourize msg.rjust(15), 0, colour
  end

  def colour_start fore, back = 1
    "\x03#{ fore.to_s.rjust(2, "0") },#{ back.to_s.rjust(2, "0") }"
  end
  
  def colour_end
    "\x03"
  end

  def colourize msg, fore, back = 1
    colour_end + colour_start(fore, back) + msg + colour_end + colour_start(0)
  end
end

class Hash
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