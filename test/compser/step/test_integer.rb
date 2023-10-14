# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestInteger < Minitest::Test
  include Compser

  def test_integer_success_single_digit
    parser = succeed.and_then(:integer)

    state = parser.call(State.new("1"))

    assert state.good?
    assert_equal "", state.chomped
    assert_equal 1, state.result.value
  end

  def test_integer_success_multiple_digits
    parser = succeed.and_then(:integer)

    state = parser.call(State.new("1234567890"))

    assert state.good?
    assert_equal "", state.chomped
    assert_equal 1234567890, state.result.value
  end

  def test_integer_success_leading_zeros
    parser = succeed.and_then(:integer)

    state = parser.call(State.new("0000001"))

    assert state.good?
    assert_equal "", state.chomped
    assert_equal 1, state.result.value
  end

  def test_integer_succeeds_trailing_symbol
    parser = succeed.and_then(:integer)

    state = parser.call(State.new("1234+"))

    assert state.good?
    assert_equal "", state.chomped
    assert_equal 1234, state.result.value
  end

  def test_integer_failure_trailing_alpha_chracter
    parser = succeed.and_then(:integer)

    state = parser.call(State.new("1234a"))

    assert state.bad?
    assert_equal "1234", state.chomped
    assert_equal "unexpected character", state.result.message
  end
end
