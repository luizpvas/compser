# frozen_string_literal: true

require "test_helper"

class Compser::State::TestChomp < ::Minitest::Test
  def test_chomp_single_line
    state = Compser::State.new("abc")

    assert_equal "", state.chomped
    assert_equal 0, state.offset
    assert_equal 0, state.line
    assert_equal 0, state.column

    assert state.chomp

    assert_equal "a", state.chomped
    assert_equal 1, state.offset
    assert_equal 0, state.line
    assert_equal 1, state.column

    assert state.chomp

    assert_equal "ab", state.chomped
    assert_equal 2, state.offset
    assert_equal 0, state.line
    assert_equal 2, state.column

    assert state.chomp

    assert_equal "abc", state.chomped
    assert_equal 3, state.offset
    assert_equal 0, state.line
    assert_equal 3, state.column

    refute state.chomp

    assert_equal "abc", state.chomped
    assert_equal 3, state.offset
    assert_equal 0, state.line
    assert_equal 3, state.column

    assert_equal "abc", state.consume_chomped
    assert_equal "", state.chomped
  end
end