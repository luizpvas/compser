# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestOneOf < Minitest::Test
  include Comparser::Parser

  def integer_or_keyword
    one_of [integer, keyword("foo")]
  end

  def test_one_of_when_first_branch_succeeds
    result = parse("123", integer_or_keyword)

    assert result.good?
    assert_equal 123, result.value
  end

  def test_one_of_when_second_branch_succeeds
    result = parse("foo", integer_or_keyword)

    assert result.good?
    assert_equal "foo", result.value
  end

  def test_one_of_commits_to_branch_once_it_succeeds
    comma_then_integer = one_of [
      symbol(",") >> integer,
      succeed
    ]

    result = parse(",a", comma_then_integer)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_one_of_when_no_branch_succeeds
    result = parse("ABC", integer_or_keyword)

    assert result.bad?
    assert_equal 'expected keyword "foo"', result.message
  end
end
