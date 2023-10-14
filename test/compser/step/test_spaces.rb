# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestSpaces < Minitest::Test
  include Compser

  def test_spaces_with_no_spaces
    parser = succeed.and_then(:spaces)

    parser.call(State.new("foo")).tap do |state|
      assert state.good?
      assert_equal "", state.chomped
    end
  end

  def test_spaces_with_whitespaces
    parser = succeed.and_then(:spaces)

    parser.call(State.new("   foo")).tap do |state|
      assert state.good?
      assert_equal "   ", state.chomped
    end
  end

  def test_spaces_with_tabs_and_newlines
    parser = succeed.and_then(:spaces)

    parser.call(State.new("  \t\r\nfoo")).tap do |state|
      assert state.good?
      assert_equal "  \t\r\n", state.chomped
    end
  end
end
