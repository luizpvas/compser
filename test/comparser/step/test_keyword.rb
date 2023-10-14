# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestKeyword < Minitest::Test
  include Comparser

  def test_keyword_with_one_character
    parser = take(:keyword, "a")

    parser.parse("a").tap do |result|
      assert result.good?
      assert_equal "a", result.value
    end
  end

  def test_keyword_with_multiple_characters
    parser = take(:keyword, "foo")

    parser.parse("foo").tap do |result|
      assert result.good?
      assert_equal "foo", result.value
    end
  end

  def test_keyword_with_symbols
    parser = take(:keyword, "and_then")

    parser.parse("and_then").tap do |result|
      assert result.good?
      assert_equal "and_then", result.value
    end
  end

  def test_keyword_with_trailing_symbol
    parser = take(:keyword, "foo")

    parser.parse("foo+").tap do |result|
      assert result.good?
      assert_equal "foo", result.value
    end
  end

  def test_keyword_with_trailing_characters
    parser = take(:keyword, "foo")

    parser.parse("foobar").tap do |result|
      assert result.bad?
      assert_equal "expected keyword \"foo\"", result.message
    end
  end
end
