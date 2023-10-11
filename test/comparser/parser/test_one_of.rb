# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestOneOf < Minitest::Test
  include Comparser::Parser

  def integer
    is_digit = ->(ch) { ch.match?(/\d/) }

    chomp_if(error_message: "expected digit", is_good: is_digit)
      ._ chomp_while(is_good: is_digit)
      ._ and_then(to_value: ->(state) { state.good! Integer(state.consume_chomped) })
  end

  def keyword
    is_lowercase_char = ->(ch) { ch.match?(/[a-z]/) }

    chomp_if(error_message: "expected keyword", is_good: is_lowercase_char)
      ._ chomp_while(is_good: is_lowercase_char)
      ._ and_then(to_value: ->(state) { state.good! state.consume_chomped })
  end

  def integer_or_keyword
    one_of [integer, keyword]
  end

  def test_one_of_when_first_branch_succeeds
    result = parse("123", integer_or_keyword)

    assert result.good?
    assert_equal 123, result.value
  end

  def test_one_of_when_second_branch_succeeds
    result = parse("abc", integer_or_keyword)

    assert result.good?
    assert_equal "abc", result.value
  end

  def test_one_of_when_no_branch_succeeds
    result = parse("ABC", integer_or_keyword)

    assert result.bad?
    assert_equal "expected keyword", result.message
  end
end
