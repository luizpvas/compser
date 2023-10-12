# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestMap < Minitest::Test
  include Comparser::Parser

  def test_map_with_callable
    integer_plus_one = map(->(x) { x + 1 }) { integer }

    result = parse("1", integer_plus_one)

    assert result.good?
    assert_equal 2, result.value
  end

  def test_map_with_constructor
    my_integer_class = Struct.new(:value)

    my_integer = map(my_integer_class) { integer }

    result = parse("1234", my_integer)

    assert result.good?
    assert_instance_of my_integer_class, result.value
    assert_equal 1234, result.value.value
  end

  def test_map_with_multiple_values
    plus_operation = map(->(x, plus, y) { x + y }) { integer >> symbol("+") >> integer }

    result = parse("1+2", plus_operation)

    assert result.good?
    assert_equal 3, result.value
  end

  def test_nested_map
    keyword_uppercase = map(->(x) { x.upcase }) { keyword("foo") }
    keyword_to_sym    = map(->(x) { x.to_sym }) { keyword_uppercase }

    result = parse("foo", keyword_to_sym)

    assert result.good?
    assert_equal :FOO, result.value
  end

  def test_map_with_failure
    keyword_uppercase = map(->(x) { x.upcase }) { keyword("foo") }

    result = parse("bar", keyword_uppercase)

    assert result.bad?
    assert_equal "expected keyword \"foo\"", result.message
  end
end
