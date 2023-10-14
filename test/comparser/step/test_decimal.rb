# frozen_string_literal: true

require "test_helper"

class Comparser::Step::DecimalTest < Minitest::Test
  include Comparser

  def test_decimal_without_floating_point
    parser = succeed.and_then(:decimal)

    parser.call(State.new("123")).tap do |state|
      assert state.good?
      assert_equal BigDecimal("123"), state.result.value
    end
  end

  def test_decimal_negative
    parser = take(:decimal)

    assert parser.parse("-123").bad?
    assert parser.parse("-123.456").bad?
    assert parser.parse("-0.000001").bad?
  end

  def test_decimal_with_floating_point
    parser = take(:decimal)

    assert_equal BigDecimal("123.456"),  parser.parse("123.456").value
    assert_equal BigDecimal("0.000001"), parser.parse("0.000001").value
  end

  def test_decimal_without_leading_digits
    parser = take(:decimal)

    parser.parse(".123").tap do |result|
      assert result.bad?
      assert_equal "unexpected character", result.message
    end
  end

  def test_decimal_without_trailing_digits
    parser = take(:decimal)

    parser.parse("123.").tap do |result|
      assert result.bad?
      assert_equal "unexpected eof", result.message
    end
  end

  def test_decimal_with_trailing_alpha_character
    parser = take(:decimal)

    parser.parse("123.456a").tap do |result|
      assert result.bad?
      assert_equal "unexpected character", result.message
    end
  end
end
