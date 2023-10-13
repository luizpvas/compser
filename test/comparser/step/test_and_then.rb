# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestAndThen < Minitest::Test
  include Comparser

  def test_and_then_with_identity_function
    parser = succeed.and_then(->(state) { state })

    state = State.new("")

    assert_equal state, parser.call(state)
  end

  def test_and_then_with_transformation
    parser = succeed.and_then(->(state) { state.chomp })

    state = parser.call(State.new("a"))

    assert_equal "a", state.chomped
  end

  def test_and_then_with_multiple_calls
    calls = []

    parser = succeed
      .and_then(->(state) { calls << 1; state })
      .and_then(->(state) { calls << 2; state })

    parser.call(State.new("a"))

    assert_equal [1, 2], calls
  end

  def test_and_then_with_block
    calls = []

    parser = succeed
      .and_then { |state| calls << 1; state }
      .and_then { |state| calls << 2; state }

    parser.call(State.new("a"))

    assert_equal [1, 2], calls
  end

  def test_and_then_without_callable
    parser = succeed

    assert_raises(ArgumentError) { parser.and_then }
    assert_raises(ArgumentError) { parser.and_then("foo") }

    succeed
      .and_then(:chomp_if, ->(x) { x == "foo" })
  end

  def test_and_then_consume_chomped_and_push_result_to_stack
    parser = succeed
      .and_then(:chomp_if, ->(ch) { ch == "a" })
      .and_then(:chomp_if, ->(ch) { ch == "b" })
      .and_then { |state| state.good!(state.consume_chomped) }

    state = parser.call(State.new("ab"))

    assert state.good?
    assert_equal "", state.chomped
    assert_equal "ab", state.result.value
  end

  def test_and_then_does_not_call_next_step_if_state_is_bad
    calls = []
    
    parser = succeed.and_then(->(state) { calls << 1; state })

    parser.call(State.new("abc").bad!("something went wrong"))

    assert_equal [], calls
  end
end
