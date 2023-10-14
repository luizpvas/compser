# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestChompWhile < Minitest::Test
  include Compser

  def test_chomp_while_succeeds_without_matching_any_characters
    parser = succeed.and_then(:chomp_while, ->(ch) { ch == "a" })

    state = parser.call(State.new("b"))

    assert state.good?
    assert_equal "", state.chomped
  end

  def test_chomp_while_matching_some_characters
    parser = succeed.and_then(:chomp_while, ->(ch) { ch == "a" })

    state = parser.call(State.new("aaabb"))

    assert state.good?
    assert_equal "aaa", state.chomped
  end

  def test_chomp_while_matching_all_characters
    parser = succeed.and_then(:chomp_while, ->(ch) { true })

    state = parser.call(State.new("aaaabb"))

    assert state.good?
    assert state.eof?
    assert_equal "aaaabb", state.chomped
  end
end
