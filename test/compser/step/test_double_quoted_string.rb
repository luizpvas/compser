# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestDoubleQuotedString < Minitest::Test
  include Compser

  def test_single_word
    parser = succeed.and_then(:double_quoted_string)

    parser.call(Compser::State.new('"hello"')).tap do |state|
      assert state.good?
      assert_equal "hello", state.result.value
    end
  end

  def test_multiple_words
    parser = succeed.and_then(:double_quoted_string)

    parser.call(Compser::State.new('"hello world"')).tap do |state|
      assert state.good?
      assert_equal "hello world", state.result.value
    end
  end

  def test_line_break
    source = <<~CODE
      "hello
        world"
    CODE

    parser = succeed.and_then(:double_quoted_string)

    parser.call(Compser::State.new(source)).tap do |state|
      assert state.good?
      assert_equal "hello\n  world", state.result.value
    end
  end

  def test_escape
    parser = succeed.and_then(:double_quoted_string)

    parser.call(Compser::State.new('"hello \"world\""')).tap do |state|
      assert state.good?
      assert_equal 'hello \\"world\\"', state.result.value
    end
  end

  def test_unclosed_string_reaching_eof
    parser = succeed.and_then(:double_quoted_string)

    parser.call(Compser::State.new('"hello')).tap do |state|
      assert state.bad?
      assert_equal "unexpected eof", state.result.message
    end
  end
end
