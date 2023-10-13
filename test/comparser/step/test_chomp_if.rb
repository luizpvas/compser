# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestChompIf < Minitest::Test
  include Comparser

  def test_chomp_if_success
    parser = succeed.and_then(:chomp_if, ->(ch) { ch == "a" })

    state = parser.call(State.new("a"))

    assert_equal "a", state.chomped
  end
end
