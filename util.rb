module Utilities
  def colour_start foreground, background = 0
    "\x03#{ foreground.to_s.rjust(2, "0") },#{ background.to_s.rjust(2, "0") }"
  end
  
  def colour_end
    "\x03"
  end

  def colourize msg, colour = 1
    colour_end + colour_start(0, colour) + msg + colour_end + colour_start(0, 1)
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
  
  def + num
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = v + num
      end
    end
  end
  
  def - num
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = v - num
      end
    end
  end
  
  def * num
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = v * num
      end
    end
  end
  
  def / num
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = v / num
      end
    end
  end
end