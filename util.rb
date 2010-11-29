class Hash
  # Proper invert, values are not always unique.
  # Input: a => b, c => b, d => e
  # Output: b => [a, c], e => [d]
  def invert_pro
    self.class.new.tap do |hash|
      self.each do |k, v|
        (hash[v] ||= []) << k
      end
    end
  end
  
  def invert_pro_size
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[v] = 0 unless hash[v]
        hash[v] += 1
      end
    end
  end

  # Input: a => [b, c], d => [e] 
  # Output: b => [a], c => [a], e => [d]
  def invert_arr
    self.class.new.tap do |hash|
      self.each do |k, v|
        v.each do |w| 
          (hash[w] ||= []) << k
        end
      end
    end
  end
  
  def invert_arr_size
    self.class.new.tap do |hash|
      self.each do |k, v|
        v.each do |w|
          hash[w] = 0 unless hash[w]
          hash[w] += 1
        end
      end
    end
  end
  
  def multiply num 
    self.class.new.tap do |hash|
      self.each do |k, v|
        hash[k] = v * num
      end
    end
  end
end