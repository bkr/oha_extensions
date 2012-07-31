#This class adds the stats methods to array which computes sum, min, max, med, mean, count, std deviation
module ArrayExtension
  #Given an array of values it returns the mean, median, min, max in a hash
  #*array*:: An array whose values are used to calculate the various statistics
  #returns:: A hash with the following keys
  #* sum
  #* mean
  #* min
  #* max
  #* median
  #* count (number of items in the array)
  #<b> All keys will => 0, if the array is empty</b>
  #<b> The array is automatically sorted when you call stats</b>
  def stats
    return {:sum => 0, :mean => 0, :min => 0, :max => 0, :median => 0, :std_dev => 0, :count => 0} if empty?
    out = Hash.new
    sort!
    out[:sum] = inject(0){|sum, element| sum + element}
    out[:mean] = out[:sum]/size.to_f
    out[:min] = min
    out[:max] = max
    out[:median] = size % 2 == 0 ? (self[size/2] + self[size/2 - 1]) / 2.0 : self[size/2]
    out[:count] = size
    if size > 1
      out[:std_dev] = Math.sqrt((inject(0){|sum_square, element| sum_square += element * element} - out[:sum]*out[:mean]) / (size - 1)) 
    else
      out[:std_dev] = 0
    end
    return out
  end

  #returns:: The average value of the elements in the array
  def average
    return stats[:sum] / size.to_f
  end
  
  #Divides the calling array into +batch_size+ batches, (the last batch could be less than +batch_size+ if the calling array.size % batch_size != 0) and yields each batch
  #*batch_size*:: The number elements to yield to the given block
  #Example:
  # (1..30).to_a.process_in_batches(10) do |batch|
  #   p batch
  # end
  #
  # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  # [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  # [21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
  def process_in_batches(batch_size)
    raise ArgumentError if batch_size.nil? or batch_size <= 0
    
    index = 0
    
    while index < self.size
      yield self[index...index+batch_size]
      index += batch_size
    end
  end
  
  def to_hash_with_keys(options={}, &block)
    options = {:value_acts_as_array => false}.merge(options)
    return self.inject(Hash.new) do |injection, var| 
      key = block.call(var)
      if options[:value_acts_as_array]
        if injection[key].nil?
          injection[key] = [var]
        else
          injection[key] << var
        end
      else
        injection[key] = var
      end
      
      injection
    end
  end
  
  def to_lookup_hash()
    h = Hash.new
    self.each do |e|
      h[e] = block_given? ? yield(e) : true
    end
    return h
  end
  
  # useful for creating in memory mappings of ActiveRecord models
  def to_identity_hash(id_proc = nil)
    h = Hash.new
    self.each do |e|
      key = id_proc ? id_proc.call(e) : (block_given? ? yield(e) : e.id)
      h[key] = e
    end
    return h
  end
  
  def rand
    self[Kernel.rand(self.length)]
  end
  
  def next
    @next_index = @next_index.nil? ? 0 : (@next_index + 1) % self.size
    return self[@next_index]
  end
  
  def shuffle
    self.sort_by{ Kernel.rand }
  end
  
  def delete_first(element)
    index = self.index(element)
    self.delete_at(index) if index
  end
end