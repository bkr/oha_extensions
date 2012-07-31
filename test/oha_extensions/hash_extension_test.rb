require "test_helper"

class HashExtensionTest < Test::Unit::TestCase
  
  def setup
    @simple = {:a => 1, :b => 2, :c => 3}
    @simple_sum = 6
    
    @zeros = {:zero => 0, :another_zero => 0, :yet_another_zero => 0}
    
    @integers = {:an_integer => 48, :an_negative => -77, :zero => 0}
    @integers_sum = -29
    
    @floats = {:a_float => 24.5, :a_negative_float => -74.8, :zero => 0.0}
    @floats_sum = -50.3

    @mixed = @integers.merge(@floats)
    @mixed_sum = @integers_sum + @floats_sum        
  end
  
  def test_empty
    assert_equal 0, {}.sum
    assert_equal 0, {}.sum { |k, v| v }
  end
  
  def test_zeros
    assert_equal 0, @zeros.sum
  end
  
  def test_integers
    assert_equal @integers_sum, @integers.sum
  end

  def test_floats
    assert_equal @floats_sum, @floats.sum
  end    
  
  def test_mixed
    assert_equal @mixed_sum, @mixed.sum
  end
  
  def test_block
    test = {:a => ['foo', 48], :b => ['monkey', -99], :c => ['bunny', 34]}
    
    #sum index 1 of each element
    assert_equal -17, test.sum { |k, v| v[1] }

    #sum index 0
    assert_match 'foo', test.sum { |k, v| v[0] }
    assert_match 'monkey', test.sum { |k, v| v[0] }
    assert_match 'bunny', test.sum { |k, v| v[0] }
    
    #sum key
    assert_match 'a', test.sum { |k, v| k.to_s }
    assert_match 'b', test.sum { |k, v| k.to_s }
    assert_match 'c', test.sum { |k, v| k.to_s }
    
    #sum entire array 
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == 'foo' }
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == 'monkey' }
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == 'bunny' }
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == 48 }
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == -99 }
    assert_equal true, test.sum { |k, v| v }.any? { |e| e == 34 }
    
    #sum manipulating value
    assert_equal 0, test.sum { |k, v| v[1] - v[1] }
    assert_equal -34, test.sum { |k, v| v[1] * 2 }
    assert_equal [], test.sum { |k, v| v - v }
  end
  
  
  def test_increment
    h = Hash.new
    
    assert_equal nil, h['foo']
    assert_equal 1, h.increment('foo')
    assert_equal 2, h.increment('foo')
    
    h = Hash.new 
    assert_equal 10, h.increment(['foo'], 10)
    assert_equal 20, h.increment(['foo'], 10)
    
    age = Hash.new
    age['0 - 18'] = 0
    age['18 - 24'] = 0
    age['24 - 99999'] = 0
    
    age.increment(18) do |v, e|
      min, max = e.split(' - ')
       v >= min.to_i && v < max.to_i
    end
    
    assert_equal(0, age['0 - 18'])
    assert_equal(1, age['18 - 24'])
    assert_equal(0, age['24 - 99999'])
  end
  
  def test_percent
    h = {'a' => 25, 'b' => 50, 'c' => 25}
    assert_in_delta(0.25, h.percent('a'), 2 ** -20)
    assert_in_delta(0.50, h.percent('b'), 2 ** -20)
    assert_in_delta(0.25, h.percent('c'), 2 ** -20)
    
    h = {'hot' => ['steamy', 3], 'hotter' => ['smoking', 4], 'hottest' => ['global warming', 7]}
    assert_in_delta(0.21428571428571428571, h.percent('hot') { |v| v[1] }, 2 ** -20)
    assert_in_delta(0.28571428571428571428, h.percent('hotter') { |v| v[1] }, 2 ** -20)
    assert_in_delta(0.5, h.percent('hottest') { |v| v[1] }, 2 ** -20)

    assert_raise(NoMethodError) { h.percent('cold') }
    
    h = {'a' => 0}
    assert_equal 0, h.percent('a')    
  end
  
  context ".select_pairs" do
    context "empty" do
      setup do
        @hash = {}
        @execute_result = @hash.select_pairs { |k, v| v % 2 == 0 }
      end
      
      should "return empty hash" do
        assert_equal({}, @execute_result)
      end      
    end
    
    context "populated" do
      setup do
        @hash = {'A' => 1, 'B' => 2}
        @execute_result = @hash.select_pairs { |k, v| v % 2 == 0 }
      end
      
      should "return hash where values are even" do
        assert_equal({'B' => 2}, @execute_result)
      end
    end
  end

  context ".from_xml_string" do
    should "handle empty root node" do
      xml = '<a />'
      expected = {'a' => nil}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle empty string root node" do
      xml = '<a></a>'
      expected = {'a' => nil}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle text string root node" do
      xml = '<a>text</a>'
      expected = {'a' => 'text'}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle attributes in root node" do
      xml = '<a a1="aye1" />'
      expected = {'a' => {'a1' => 'aye1', 'a' => nil}}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle element nodes" do
      xml = '<a><b>value</b></a>'
      expected = {'a' => {'b' => 'value'}}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle empty element nodes" do
      xml = '<a><b/><c/></a>'
      expected = {'a' => {'b' => nil, 'c' => nil}}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "handle attributes in nodes" do
      xml = '<a a1="aye1" a2="aye2"><b b1="bee1"/><c c1="see1">see2</c></a>'
      expected = {'a' => {'a1' => 'aye1', 'a2' => 'aye2', 'a' => {
        'b' => {'b1' => 'bee1', 'b' => nil},
        'c' => {'c1' => 'see1', 'c' => 'see2'}}}}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    should "flatten array nodes by default" do
      xml = '<a><b>bee1</b><b>bee2</b><c /></a>'
      expected = {'a' => {'b' => 'bee1', 'c' => nil}}
      assert_equal expected, Hash.from_xml_string(xml)
    end
    
    context "with array nodes" do
      should "not flatten array nodes when array_nodes specified" do
        xml = '<a><b>bee1</b><b>bee2</b><c /></a>'
        expected = {'a' => {'b' => ['bee1', 'bee2'], 'c' => nil}}
        assert_equal expected, Hash.from_xml_string(xml, :array_nodes => ['b'])
      end
      
      should "not flatten array nodes and remove inner nodes when array_nodes and parent_array_nodes specified" do
        xml = '<a><b>bee1</b><b>bee2</b><c>see</c></a>'
        expected = {'a' => ['bee1', 'bee2', 'see']}
        assert_equal expected, Hash.from_xml_string(xml, :array_nodes => ['b', 'c'], :parent_array_nodes => ['a'])
      end
      
      should "have empty array node when no child nodes present and parent_array_nodes specified" do
        xml = '<a> \n </a>'
        expected = {'a' => []}
        assert_equal expected, Hash.from_xml_string(xml, :parent_array_nodes => ['a'])
      end
    end
  end
end
