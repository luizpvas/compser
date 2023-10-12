# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestDecimal < Minitest::Test
  include Comparser::Parser

  def test_decimal_without_floating_point
    result = parse("123", decimal)

    assert result.good?
    assert_equal BigDecimal("123"), result.value
  end

  def test_decimal_with_floating_point
    result = parse("0.0009", decimal)

    assert result.good?
    assert_equal BigDecimal("0.0009"), result.value
  end

  def test_decimal_multiple_digits_with_floating_point
    result = parse("123.456", decimal)

    assert result.good?
    assert_equal BigDecimal("123.456"), result.value
  end

  def test_decimal_failure_with_trailing_dot
    result = parse("123.", decimal)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_decimal_failure_with_prefix_dot
    result = parse(".123", decimal)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_decimal_failure_with_trailing_alpha
    result = parse("123a", decimal)

    assert result.bad?
    assert_equal "unexpected character", result.message
  end
end
