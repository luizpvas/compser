# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::State::TestPeek < ::Minitest::Test
  def test_peek
    state = Comparser::Parser::State.new("abc")

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
end
