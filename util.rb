module Utilities
  def make_title msg, fore = Const::Colour_black, back = 0
    colourize msg.to_s.rjust(15), fore, back
  end

  def colour_start fore = Const::Colour_black, back = 0
    "\x03#{ fore.to_s.rjust(2, "0") }" + "#{ ",#{ back.to_s.rjust(2, "0") }" if back != 0 }"
  end
  
  def colour_end
    "\x03"
  end
  
  def colourize msg, fore = 0, back = 0
    colour_start(fore, back) + msg.to_s + colour_end
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