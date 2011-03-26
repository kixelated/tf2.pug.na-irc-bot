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
end
