require 'nokogiri'

module HashExtension

  #returns:: The sum of each element in the hash
  #An optional block can be given which takes two parameters, key and value for each element in the hash.  The return value of the block is summed for each element in the hash.
  #If the result of sum is nil, 0 is returned
  #Examples:
  # {:a => 1, :b => 2, :c => 3}.sum #returns 6
  # {:a => ['foo', 1], :b => ['monkey', 2], :c => ['bunny', 3]}.sum { |k, v| v[1] } #returns 6
  # {:a => ['foo', 1], :b => ['monkey', 2], :c => ['bunny', 3]}.sum { |k, v| v } #returns ['foo', 1, 'monkey', 2, 'bunny', 3] <b>Order of elements is NOT guaranteed</b>
  # {}.sum #returns 0
  def sum(&block)
    block = lambda { |k, v| v } if block.nil?
    
    total = nil
    
    each do |k, v| 
      total.nil? ? total = block.call(k, v) : total += block.call(k, v)
    end

    return total || 0
  end

  #Increments the value pointed to from the key
  #If the key is nil then it is initialized to amount
  #An optional block may be given, which is passed +key+, and each key in the hash.  The block should return true for the key you wish to increment.
  #Examples:
  # h = Hash.new #h['foo'] = nil
  # h.increment('foo') #1
  # h.increment('foo') #2
  #
  # age = Hash.new
  # age['0 - 18'] = 0
  # age['18 - 24'] = 0
  # age['24 - 99999'] = 0
  # 
  # #increment the key where 18 is in range of the min and max
  # age.increment(18) do |v, e|
  #   min, max = e.split(' - ')
  #   v >= min.to_i && v < max.to_i
  # end
  # 
  # assert_equal(0, age['0 - 18'])
  # assert_equal(1, age['18 - 24'])
  # assert_equal(0, age['24 - 99999'])
  def increment(key, amount=1, &block)
    if block.nil?
      key_to_use = key
    else
      key_to_use = self.keys.detect { |k| block.call(key, k) } 
    end
    
    if self[key_to_use].nil?
      self[key_to_use] = amount
    else
      self[key_to_use] += amount
    end
  end
  
  #returns:: What percent of the sum of the hash is the value for +key+
  #Examples:
  # {:a => 1, :b => 2, :c => 3, :d => 4}.percent(:c) #0.30 because 3 is 30% of 10 and 10 is the total of the hash
  # {:a => ['foo', 1], :b => ['monkey', 2], :c => ['bunny', 3], :d => ['kitty', 4]}.percent(:c) { |e| e[1] } #0.30 
  # {:a => 0} #0.0, if the sum of the hash is 0, then 0 is returned
  def percent(key, &block)
    block = lambda { |v| v } if block.nil?
    sum_block = lambda { |k, v| block.call(v) }
    
    total = self.sum(&sum_block)
    return 0 if total == 0
    return block.call(self[key]) / total.to_f
  end
  
  #If keys does not include everything in required_keys, throw an ArgumentError.
  #
  #*required_keys*: list of keys that must be present for the hash (if a required key hashes to nil, but is passed it is still valid.
  #Example:: 
  #  {:happy => nil}.assert_required_keys(:happy) #will not raise error
  #required_keys may be passed as strings, symbols or both.  Likewise the keys in the has maybe a strings or symbols or both.
  #Example::
  #  {:happy => 'bunny'}.assert_required_keys(:happy) #will not raise error
  #  {'happy' => 'bunny'}.assert_required_keys(:happy) #will not raise error  
  #====Raises
  #*ArgumentError*:: if a required key is missing  
  def assert_required_keys(*required_keys)
    keys_not_passed = [required_keys].flatten.map { |required_key| required_key.to_s } - self.stringify_keys.keys
    raise(ArgumentError, "The following keys were nil when expected not to be: #{keys_not_passed.join(", ")}") unless keys_not_passed.empty?
  end
  alias_method :must_include, :assert_required_keys
  
  
  def select_pairs(&block)
    return Hash[*self.select(&block).flatten]
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    # Generates a hash from XML. This is specifically being used generate JSON for the API. It makes the assumption that elements contain arrays
    #  must be explicitly specified.  Assuming otherwise generates larger JSON.
    #  This also utilizes XML attributes which Hash.from_xml ignores.
    def from_xml_string(s, options = {})
      options = {:array_nodes => [], :parent_array_nodes => []}.merge(options)
      return node_to_hash(Nokogiri.parse(s).children.first, options)
    end
  
    private
  
    def node_to_hash(node, options)
      children = node.children.select {|n| n.element?}
      node_name = node.name
      hash = {}
    
      if ! node.attributes.empty?
        hash[node_name] = {}
        node.attributes.each do |attr_name, attr_value|
          hash[node_name][attr_name] = attr_value.to_s
        end
        content_hash = hash[node_name]
        # this is the name of the key for the sub elements, could also use something like 'content'
        node_name = node.name
      else
        content_hash = hash
      end

      if children.empty?
        nc = node.children.detect{|n| n.text?}
        content_hash[node_name] = nc.nil? ? nil : nc.text
      
        if options[:parent_array_nodes].include?(node_name)
          content_hash[node_name] = []
        end
      else
        children_hash = children.inject({}) do |acc, node|
          child_hash = node_to_hash(node, options)
          child_hash.each do |key, value|
            if options[:array_nodes].include?(key)
              acc[key] = [] if acc[key].nil?
              acc[key] << value
            else
              acc[key] = value if acc[key].nil?
            end
          end
          acc
        end
        content_hash[node_name] = children_hash
      
        if options[:parent_array_nodes].include?(node_name)
          content_hash[node_name] = children_hash.values.flatten
        end
      end
    
      return hash
    end
  end
end
