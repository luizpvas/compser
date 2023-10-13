# frozen_string_literal: true

require "test_helper"

class Comparser::State::TestPeek < ::Minitest::Test
  def test_peek_single_character
    state = Comparser::State.new("abc")

    assert_nil state.peek(-1)
    assert_equal "a", state.peek
    assert_equal "b", state.peek(1)
    assert_equal "c", state.peek(2)
    assert_nil state.peek(3)
  
    state.chomp

    assert_nil state.peek(-2)
    assert_equal "a", state.peek(-1)
    assert_equal "b", state.peek
    assert_equal "c", state.peek(1)
    assert_nil state.peek(2)
  end

  def test_peek_range
    state = Comparser::State.new("abc")

    assert_nil state.peek(-1, 2)
    assert_equal "a", state.peek(0, 1)
    assert_equal "ab", state.peek(0, 2)
    assert_equal "abc", state.peek(0, 3)
    assert_equal "bc", state.peek(1, 2)
    assert_nil state.peek(0, 4)
  end
end
