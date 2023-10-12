# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestSymbol < Minitest::Test
  include Comparser::Parser
  
  def test_symbol_success_exact_match
    result = parse("+", symbol("+"))

    assert result.good?
    assert_equal "+", result.value
  end

  def test_symbol_success_match_with_trailing_characters
    result = parse("+1", symbol("+"))

    assert result.good?
    assert_equal "+", result.value
  end

  def test_symbol_success_with_multiple_characters
    result = parse("+=10", symbol("+="))

    assert result.good?
    assert_equal "+=", result.value
  end

  def test_symbol_failure_no_match
    result = parse("1", symbol("+"))

    assert result.bad?
    assert_equal "expected symbol \"+\"", result.message
  end

  def test_symbol_failure_partial_match
    result = parse("foo", symbol("fooo"))

    assert result.bad?
    assert_equal "expected symbol \"fooo\"", result.message
  end
end
