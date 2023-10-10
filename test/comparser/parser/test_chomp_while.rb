# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestChompWhile < Minitest::Test
  include Comparser::Parser

  def chomp_digits
    chomp_while(
      is_good: ->(ch) { ch.match?(/\d/) }
    )
  end

  def test_chomp_while_full_match
    result = parse("123", chomp_digits)

    assert result.good?
    assert_nil result.value
    assert_equal "123", result.state.peek_chomped
  end

  def test_chomp_while_partial_match
    result = parse("123abc", chomp_digits)

    assert result.good?
    assert_nil result.value
    assert_equal "123", result.state.peek_chomped
  end

  def test_chomp_while_without_match
    result = parse("abc", chomp_digits)

    assert result.good?
    assert_nil result.value
    assert_equal "", result.state.peek_chomped
  end
end
