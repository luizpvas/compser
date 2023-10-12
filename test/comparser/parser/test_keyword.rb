# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestKeyword < Minitest::Test
  include Comparser::Parser

  def test_keyword_success
    result = parse("let", keyword("let"))
    
    assert result.good?
    assert "let", result.value
  end

  def test_keyword_success_trailing_symbol
    result = parse("module{", keyword("module"))

    assert result.good?
    assert "module", result.value
  end

  def test_keyword_failure_partial_match
    result = parse("modul", keyword("module"))

    assert result.bad?
    assert_equal "expected keyword \"module\"", result.message
  end

  def test_keyword_failure_trailing_character
    result = parse("letter", keyword("let"))

    assert result.bad?
    assert_equal "expected keyword \"let\"", result.message
  end
end
