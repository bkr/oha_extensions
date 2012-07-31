require "test_helper"

class ArrayExtensionTest < Test::Unit::TestCase
  
  def setup
  end
  
  def test_array_stats
    #= Test Empty
    stats = [].stats
    stats.values.all? { |e| e == 0 }
    
    #== Only 0s
    stats = Array[0].stats
    assert_equal 0, stats[:sum]
    assert_equal 0, stats[:mean]
    assert_equal 0, stats[:min]
    assert_equal 0, stats[:max] 
    assert_equal 0, stats[:median]
    assert_equal 1, stats[:count]
    assert_equal 0, stats[:std_dev]
    
    stats = Array[0, 0, 0].stats
    assert_equal 0, stats[:sum]
    assert_equal 0, stats[:mean]
    assert_equal 0, stats[:min]
    assert_equal 0, stats[:max] 
    assert_equal 0, stats[:median]
    assert_equal 3, stats[:count]
    assert_equal 0, stats[:std_dev]
    
    #== Integers
    #==== simple in order (even size)
    stats = Array[0, 1, 2, 3].stats
    assert_equal 6, stats[:sum]
    assert_in_delta(1.5, stats[:mean], 2 ** -20)
    assert_equal 0, stats[:min]
    assert_equal 3, stats[:max] 
    assert_in_delta(1.5, stats[:median], 2 ** -20)
    assert_equal 4, stats[:count]
    assert_in_delta(1.29,stats[:std_dev], 0.1)
    
    #==== simple out of order (odd size)
    stats = Array[0, 1, 2, 3, 1].stats
    assert_equal 7, stats[:sum]
    assert_in_delta(1.4, stats[:mean], 2 ** -20)
    assert_equal 0, stats[:min]
    assert_equal 3, stats[:max] 
    assert_in_delta(1, stats[:median], 2 ** -20)
    assert_equal 5, stats[:count]
    assert_in_delta(1.14,stats[:std_dev], 0.1)
    
    #==== 0 sum with negatives
    stats = Array[-99, 99, 0].stats
    assert_equal 0, stats[:sum]
    assert_in_delta(0.0, stats[:mean], 2 ** -20)
    assert_equal -99, stats[:min]
    assert_equal 99, stats[:max] 
    assert_in_delta(0.0, stats[:median], 2 ** -20)
    assert_equal 3, stats[:count]
    assert_in_delta(99, stats[:std_dev], 0.1)
    
    #==== Random
    a = rand(1000) - rand(1000)
    b = rand(1000) - rand(1000)
    c = rand(1000) - rand(1000)
    input = [a, b, c]
    stats = input.stats
    assert_in_delta((a + b + c), stats[:sum], 2 ** -20)
    assert_in_delta((a + b + c)/3.0, stats[:mean], 2 ** -20)
    assert_equal input.min, stats[:min]
    assert_equal input.max, stats[:max] 
    assert_in_delta(input[1], stats[:median], 2 ** -20)
    assert_equal 3, stats[:count]
    
    #== Floats
    #==== simple in order (even size)
    stats = Array[0.0, 1.4, 2.567, 3.8].stats
    assert_in_delta(7.767, stats[:sum], 2 ** -20)
    assert_in_delta(1.94175, stats[:mean], 2 ** -20)
    assert_in_delta(0.0, stats[:min], 2 ** -20)
    assert_in_delta(3.8, stats[:max] , 2 ** -20)
    assert_in_delta(1.9835, stats[:median], 2 ** -20)
    assert_equal 4, stats[:count]
    assert_in_delta(1.62, stats[:std_dev], 0.1)
    
    #==== simple out of order (odd size)
    stats = Array[0.0, 1.4, 2.567, 3.8, 1.378].stats
    assert_in_delta(9.145, stats[:sum], 2 ** -20)
    assert_in_delta(1.829, stats[:mean], 2 ** -20)
    assert_in_delta(0.0, stats[:min], 2 ** -20)
    assert_in_delta(3.8, stats[:max] , 2 ** -20)
    assert_in_delta(1.4, stats[:median], 2 ** -20)
    assert_equal 5, stats[:count]
    assert_in_delta(1.428, stats[:std_dev], 0.1)
    
    
    #==== 0 sum with negatives
    stats = Array[-99.88, 99.88, 0].stats
    assert_in_delta(0.0, stats[:sum], 2 ** -20)
    assert_in_delta(0.0, stats[:mean], 2 ** -20)
    assert_in_delta(-99.88, stats[:min], 2 ** -20)
    assert_in_delta(99.88, stats[:max] , 2 ** -20)
    assert_in_delta(0.0, stats[:median], 2 ** -20)
    assert_equal 3, stats[:count]
    assert_in_delta(99.88, stats[:std_dev], 0.1)
    
    
    #==== Random
    a = rand() * rand(1000) - rand() * rand(1000)
    b = rand() * rand(1000) - rand() * rand(1000)
    c = rand() * rand(1000) - rand() * rand(1000)
    input = [a, b, c]
    stats = input.stats
    assert_in_delta((a + b + c), stats[:sum], 2 ** -20)
    assert_in_delta((a + b + c)/3.0, stats[:mean], 2 ** -20)
    assert_in_delta(input.min, stats[:min], 2 ** -20)
    assert_in_delta(input.max, stats[:max] , 2 ** -20)
    assert_in_delta(input[1], stats[:median], 2 ** -20)
    assert_equal 3, stats[:count]
    
    #== Mixed
    a = rand() * rand(1000) - rand() * rand(1000)
    b = rand() * rand(1000) - rand() * rand(1000)
    c = rand() * rand(1000) - rand() * rand(1000)
    d = rand(1000) - rand(1000)
    e = rand(1000) - rand(1000)
    f = rand(1000) - rand(1000)
    input = [a, b, c, d, e, f]
    stats = input.stats
    assert_in_delta((a + b + c + d + e + f), stats[:sum], 2 ** -20)
    assert_in_delta((a + b + c + d + e + f)/6.0, stats[:mean], 2 ** -20)
    assert_in_delta(input.min, stats[:min], 2 ** -20)
    assert_in_delta(input.max, stats[:max] , 2 ** -20)
    assert_in_delta((input[3] + input[2])/2.0, stats[:median], 2 ** -20)
    assert_equal 6, stats[:count]
  end

  def test_average
    assert_equal 0, [-1, 0, 1].average
    assert_equal 1, [1].average
    assert_equal 46.5, [10, 45, 34, 97].average
    assert_equal 66.065, [34.7, 97.43].average
    
    a = rand() * rand(1000) - rand() * rand(1000)
    b = rand() * rand(1000) - rand() * rand(1000)
    c = rand() * rand(1000) - rand() * rand(1000)
    d = rand(1000) - rand(1000)
    e = rand(1000) - rand(1000)
    f = rand(1000) - rand(1000)
    input = [a, b, c, d, e, f]
    assert_in_delta((a + b + c + d + e + f)/6.0, input.average, 2 ** -20)
  end
  
  #======================================================================
  #====================== Test process_in_batches =======================
  #======================================================================
  def setup_process_in_batches_tests
    @array = %W[one two three four five six seven eight nine ten]
    @empty = Array.new
  end

  def test_process_in_batches_missing_batch_size_argument
    setup_process_in_batches_tests
    assert_raise(ArgumentError) { @array.process_in_batches }
  end
  
  def test_process_in_batches_empty_array
    setup_process_in_batches_tests
    assert_nil @empty.process_in_batches(3)
  end

  def test_process_in_batches_batch_size_less_than_or_equal_to_zero
    setup_process_in_batches_tests
    assert_raise(ArgumentError) { @array.process_in_batches(0) }
    assert_raise(ArgumentError) { @array.process_in_batches(-3) }
  end
  
  def test_process_in_batches_batch_size_less_than_array_size
    setup_process_in_batches_tests

    #should get three batchs; two with 4 elements and one with 2 elements
    batch_size = 4
    batch_cnt = 0
    
    @array.process_in_batches(batch_size) do |batch|
      case batch_cnt
      when 0, 1
        assert_equal batch_size, batch.size
      when 2
        assert_equal 2, batch.size
      end
      batch_cnt += 1
    end

    assert_equal 3, batch_cnt
  end
  
  def test_process_in_batches_batch_size_greater_than_array_size
    setup_process_in_batches_tests

    #should get one batch only 
    batch_size = @array.size + 1
    batch_cnt = 0
      
    @array.process_in_batches(batch_size) do |batch|
      batch_cnt += 1
      assert_equal @array.size, batch.size
    end
    assert_equal 1, batch_cnt
  end
  
  def test_process_in_batches_batch_size_equal_to_array_size
    setup_process_in_batches_tests

    #should get one batch only
    batch_size = @array.size
    batch_cnt = 0
    
    @array.process_in_batches(batch_size) do |batch|
      batch_cnt += 1
      assert_equal @array.size, batch.size
    end
    assert_equal 1, batch_cnt
  end  
  #======================================================================
  #==================== End test process_in_batches =====================
  #======================================================================
  
  def test_to_hash_with_keys
    assert_equal({}, [].to_hash_with_keys { |e| e })
    
    actual = [1, 2, 3, 4].to_hash_with_keys { |e| e + 10 }
    expected = {11 => 1, 12 => 2, 13 => 3, 14 => 4}
    assert_equal(expected, actual)
    
    actual = [{:msg => 'apples'}, {:msg => 'foos'}, {:msg => 'cows'}].to_hash_with_keys { |e| "i_like_#{e[:msg]}".to_sym }
    expected = { :i_like_apples => {:msg => 'apples'}, :i_like_foos => {:msg => 'foos'}, :i_like_cows => {:msg => 'cows'} }
    assert_equal(expected, actual)
  end
  
  def test_to_lookup_hash
    assert_equal({}, [].to_lookup_hash)
    assert_equal({1 => true, 2 => true, 3 => true}, [1, 2, 3].to_lookup_hash)
    assert_equal({1 => 2, 2 => 3, 3 => 4}, [1, 2, 3].to_lookup_hash {|e| e + 1})
  end
  
  context "to_identity_hash" do
    should "use id attribute as key with no args" do
      o1 = mock
      o1.stubs(:id).returns(123)
      o2 = mock
      o2.stubs(:id).returns(456)
      o3 = mock
      o3.stubs(:id).returns(789)
      assert_equal({o1.id => o1, o2.id => o2, o3.id => o3}, [o1, o2, o3].to_identity_hash)
    end
    
    should "allow symbol proc as the first argument for key creation" do
      o1 = mock
      o1.stubs(:foo).returns(123)
      o2 = mock
      o2.stubs(:foo).returns(456)
      o3 = mock
      o3.stubs(:foo).returns(789)
      assert_equal({o1.foo => o1, o2.foo => o2, o3.foo => o3}, [o1, o2, o3].to_identity_hash(&:foo))
    end
    
    should "allow proc to specify key" do
      o1 = mock
      o1.stubs(:foo).returns(123)
      o2 = mock
      o2.stubs(:foo).returns(456)
      o3 = mock
      o3.stubs(:foo).returns(789)
      assert_equal({o1.foo => o1, o2.foo => o2, o3.foo => o3}, [o1, o2, o3].to_identity_hash {|e| e.foo})
    end
  end
  

  context "rand" do
    context "empty array" do
      setup do
        @execute_result = [].rand
      end
      
      should "be nil" do
        assert_nil(@execute_result)
      end
    end
    
    context "array with 1 item" do
      setup do
        @execute_result = ['foo'].rand
      end
      
      should "be just that item" do
        assert_equal 'foo', @execute_result
      end
    end
    
    context "array with multiple items" do
      setup do
        @array = ['a', 'b', 'c']
        @execute_result = @array.rand
      end
      
      should "return an item from the array" do
        assert_contains(@array, @execute_result)
      end
    end
  end
  
  context "next" do
    context "empty array" do
      should "return nil" do
        assert_equal nil, [].next
      end
    end
    
    context "single element" do
      setup do
        @element = 1
        @array = [@element]
      end
      
      should "always return only element" do
        assert_equal @element, @array.next
        assert_equal @element, @array.next
        assert_equal @element, @array.next
      end
    end
    
    context "multiple elements" do
      setup do
        @array = [1, 'a']
      end
      
      should "loop" do
        assert_equal 1, @array.next
        assert_equal 'a', @array.next
        assert_equal 1, @array.next
      end
    end
  end
  
  context "delete_first" do
    context "empty array" do
      should "return nil" do
        assert_equal nil, [].delete_first("a")
      end
    end
    
    context "multiple elements" do
      setup do
        @ary = [1,'a',3,'a']
      end
      
      should "delete first element found" do
        deleted = @ary.delete_first('a')
        assert_equal 'a', deleted
        assert_equal [1, 3, 'a'], @ary
      end
      
      should "return nil if nothing found" do
        deleted = @ary.delete_first('b')
        assert_equal nil, deleted
        assert_equal [1, 'a', 3, 'a'], @ary
      end
    end
  end
  
end