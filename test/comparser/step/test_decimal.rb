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

  def test_decimal_with_floating_point
    parser = succeed.and_then(:decimal)

    parser.call(State.new("123.456")).tap do |state|
      assert state.good?
      assert_equal BigDecimal("123.456"), state.result.value
    end

    parser.call(State.new("0.000001")).tap do |state|
      assert state.good?
      assert_equal BigDecimal("0.000001"), state.result.value
    end
  end

  def test_decimal_without_leading_digits
    parser = succeed.and_then(:decimal)

    parser.call(State.new(".123")).tap do |state|
      assert state.bad?
      assert_equal "unexpected character", state.result.message
    end
  end

  def test_decimal_without_trailing_digits
    parser = succeed.and_then(:decimal)

    parser.call(State.new("123.")).tap do |state|
      assert state.bad?
      assert_equal "unexpected eof", state.result.message
    end
  end

  def test_decimal_with_trailing_alpha_character
    parser = succeed.and_then(:decimal)

    parser.call(State.new("123.456a")).tap do |state|
      assert state.bad?
      assert_equal "unexpected character", state.result.message
    end
  end
end
