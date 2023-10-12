# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestRecursion < Minitest::Test
  include Comparser::Parser

  def comma_separated_integer
    map(->(*integers) { integers }) { comma_separated_integer_helper }
  end

  def comma_separated_integer_helper
    integer
      .-(spaces)
      .+(one_of([
        succeed - symbol(",") - spaces + lazy(-> { comma_separated_integer_helper }),
        succeed
      ]))
  end

  def test_recursion_success_with_one_call
    result = parse("1", comma_separated_integer)

    assert result.good?
    assert_equal [1], result.value
  end

  def test_recursion_success_with_multiple_calls
    result = parse("1, 2, 3", comma_separated_integer)

    assert result.good?
    assert_equal [1, 2, 3], result.value
  end

  def test_recursion_failure_with_one_iteration
    result = parse(",", comma_separated_integer)

    assert result.bad?
    assert_equal "expected digit", result.message

    result = parse("1,", comma_separated_integer)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_recursion_failure_with_multiple_iterations
    result = parse("1, 2, 3,", comma_separated_integer)

    assert result.bad?
    assert_equal "expected digit", result.message
  end
end
