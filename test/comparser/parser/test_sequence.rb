# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestLoop < Minitest::Test
  include Comparser::Parser

  def comma_separated_integers
    helper = sequence do |continue|
      integer
        .-(spaces)
        .+(one_of([
          succeed - symbol(",") - spaces + continue,
          succeed
        ]))
    end

    map(->(*integers) { integers }) { helper }
  end

  def test_loop_success_with_one_call
    result = parse("1", comma_separated_integers)

    assert result.good?
    assert_equal [1], result.value
  end

  def test_loop_success_with_multiple_calls
    result = parse("1, 2, 3", comma_separated_integers)

    assert result.good?
    assert_equal [1, 2, 3], result.value
  end

  def test_loop_failure_with_one_iteration
    result = parse(",", comma_separated_integers)

    assert result.bad?
    assert_equal "expected digit", result.message

    result = parse("1,", comma_separated_integers)

    assert result.bad?
    assert_equal "expected digit", result.message
  end

  def test_loop_failire_with_multiple_iterations
    result = parse("1, 2, 3,", comma_separated_integers)

    assert result.bad?
    assert_equal "expected digit", result.message
  end
end
