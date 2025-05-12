# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestKeywordi < Minitest::Test
  include Compser

  def test_keywordi_with_one_character
    parser = take(:keywordi, "a")

    parser.parse("A").tap do |result|
      assert result.good?
      assert_equal "A", result.value
    end
  end

  def test_keywordi_with_multiple_characters
    parser = take(:keywordi, "foo")

    parser.parse("FoO").tap do |result|
      assert result.good?
      assert_equal "FoO", result.value
    end
  end

  def test_keywordi_with_symbols
    parser = take(:keywordi, "and_then")

    parser.parse("And_Then").tap do |result|
      assert result.good?
      assert_equal "And_Then", result.value
    end
  end

  def test_keywordi_with_trailing_symbol
    parser = take(:keywordi, "math")

    parser.parse("MATH+").tap do |result|
      assert result.good?
      assert_equal "MATH", result.value
    end
  end

  def test_keywordi_with_trailing_characters
    parser = take(:keywordi, "foo")

    parser.parse("FOObar").tap do |result|
      assert result.bad?
      assert_equal "expected keyword \"foo\"", result.message
    end
  end
end
