# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestDoubleQuotedString < Minitest::Test
  include Comparser::Parser

  def test_success_with_single_word
    result = parse("\"hello\"", double_quoted_string)

    assert result.good?
    assert_equal "hello", result.value
  end

  def test_success_with_multiple_words
    result = parse("\"hello world\"", double_quoted_string)

    assert result.good?
    assert_equal "hello world", result.value
  end

  def test_success_with_empty_string
    result = parse("\"\"", double_quoted_string)

    assert result.good?
    assert_equal "", result.value
  end

  def test_success_with_escaped_quote
    result = parse('"this is a \\" quote"', double_quoted_string)

    assert result.good?
    assert_equal 'this is a \" quote', result.value
  end

  def test_success_with_multiline_string
    code = <<~CODE
    "hello
      world"
    CODE

    result = parse(code, double_quoted_string)

    assert result.good?
    assert_equal "hello\n  world", result.value
  end

  def test_failure_without_closing_quote
    result = parse("\"hello", double_quoted_string)

    assert result.bad?
    assert_equal "expected \"", result.message
  end
end
