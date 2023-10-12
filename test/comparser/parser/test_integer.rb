# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestInteger < Minitest::Test
  include Comparser::Parser
  
  def test_integer_success_single_digit
    result = parse("1", integer)

    assert result.good?
    assert_equal 1, result.value
  end

  def test_integer_success_multiple_digits
    result = parse("123", integer)

    assert result.good?
    assert_equal 123, result.value
  end

  def test_integer_success_with_a_lot_of_digits
    result = parse("12345678900000000", integer)
    
    assert result.good?
    assert_equal 12345678900000000, result.value
  end

  def test_integer_success_with_trailing_symbols
    result = parse("123+", integer)

    assert result.good?
    assert_equal 123, result.value
  end

  def test_integer_failure_with_no_digits
    result = parse("a", integer)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_integer_failure_with_trailing_characters
    result = parse("1a", integer)

    assert result.bad?
    assert_equal "unexpected character", result.message
  end
end
