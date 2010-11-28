module Util
  def Util.hash_invert_a hash
    Hash.new.tap do |c|
      hash.each do |k, v|
        v.each do |w| 
          (c[w] ||= []) << k
        end
      end
    end
  end
  
  def Util.hash_count hash
    Hash.new.tap do |c|
      hash.each_value do |v|
        c[v] = 0
      end
    
      hash.each do |k, v|
        c[v] += 1
      end
    end
  end
end