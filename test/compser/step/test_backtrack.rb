# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestBacktrack < Minitest::Test
  include Compser

  def test_backtrack_with_failure
    parser = succeed.and_then(:backtrack, take(:integer))

    parser.parse("foo").tap do |result|
      assert result.good?
      assert_nil result.value
    end
  end

  def test_multiple_backtracks_in_one_of_branches
    parser = take(:one_of, [
      take(:backtrack, drop(:token, "+").take(:token, "foo")),
      take(:backtrack, drop(:token, "+").take(:token, "bar")),
      drop(:token, "+").take(:token, "qux")
    ])

    parser.parse("+qux").tap do |result|
      assert result.good?
      assert_equal "qux", result.value
    end
  end
end
