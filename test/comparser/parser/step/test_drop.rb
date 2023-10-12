# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::Step::TestDrop < Minitest::Test
  include Comparser::Parser

  def test_drop
    integer_then_spaces_then_comma = integer.drop(symbol(",")).drop(spaces)

    result = parse("1, ", integer_then_spaces_then_comma)

    assert result.good?
    assert_equal 1, result.value
    assert_equal 2, result.state.result_stack.size # nil + 1
    assert_equal "", result.state.chomped
  end

  def test_drop_with_operator_syntax
    integer_then_spaces_then_comma = integer - symbol(",") - spaces

    result = parse("1, ", integer_then_spaces_then_comma)

    assert result.good?
    assert_equal 1, result.value
    assert_equal 2, result.state.result_stack.size # nil + 1
    assert_equal "", result.state.chomped
  end

  def test_drop_with_failure
    integer_then_spaces_then_comma = integer - symbol(",") - spaces

    result = parse("1", integer_then_spaces_then_comma)

    assert result.bad?
    assert_equal "expected symbol \",\"", result.message
  end
end
