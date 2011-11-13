require File.expand_path('../../test_helper', __FILE__)
require 'stringio'

class ParserTest < Test::Unit::TestCase

  def test_parsing_strings
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new(%["a string"]))
    assert_equal "a string", output
  end

  def test_parsing_integers
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("15 "))
    assert_equal 15, output
  end

  def test_parsing_keywords
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new(":keyword"))
    assert_equal :keyword, output
  end

  def test_parsing_nil
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("nil"))
    assert_equal nil, output
  end

  def test_parsing_true
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("true"))
    assert_equal true, output
  end

  def test_parsing_false
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("false"))
    assert_equal false, output
  end

  def test_parsing_terminating_numbers
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new(%[15]))
    assert_equal 15, output
  end

  def test_parsing_vectors
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("[14 15]"))
    assert_equal [14, 15], output
  end

  def test_parsing_nested_vectors
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("[14 [15]]"))
    assert_equal [14, [15]], output
  end

  def test_parsing_lists
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("(14 15)"))
    assert_equal [14, 15], output
  end

  def test_parsing_maps
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("{:a 1}"))
    assert_equal({:a => 1}, output)
  end

  def test_parsing_nested_maps
    reader = Clojure::Reader.new
    output = reader.read(StringIO.new("{:a {:b 1}}"))
    assert_equal({:a => {:b => 1}}, output)
  end

end
