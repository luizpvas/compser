# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestChompIf < Minitest::Test
  include Compser

  def test_chomp_if_success
    parser = succeed.and_then(:chomp_if, ->(ch) { ch == "a" })

    state = parser.call(State.new("a"))

    assert_equal "a", state.chomped
  end

  def test_chomp_if_failure
    parser = succeed.and_then(:chomp_if, ->(ch) { ch == "a" })

    state = parser.call(State.new("b"))

    assert state.bad?
    assert "unexpected character", state.result.message
    assert_equal "", state.chomped
  end
end
