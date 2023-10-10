# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestChompIf < Minitest::Test
  include Comparser::Parser

  def chomp_digit
    chomp_if(
      error_message: "expected a digit",
      is_good: ->(ch) { ch.match?(/\d/) }
    )
  end
  
  def test_chomp_if_success
    result = parse("1", chomp_digit)

    assert result.good?
    assert_nil result.value

    assert_equal "1", result.state.peek_chomped
  end

  def test_chomp_if_failure
    result = parse("a", chomp_digit)

    assert result.bad?
    assert_equal "expected a digit", result.message

    assert_equal "", result.state.peek_chomped
  end
end
