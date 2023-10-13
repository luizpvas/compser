# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestDrop < Minitest::Test
  include Comparser

  def test_drops_chomped_string
    parser = succeed.drop(:chomp_while, ->(ch) { ch == 'a' })

    parser.call(State.new("aaabb")).tap do |state|
      assert state.good?
      assert_equal 3, state.offset
      assert_equal '', state.chomped
    end
  end

  def test_drops_results
    parser = succeed.drop(:integer)

    parser.call(State.new("123")).tap do |state|
      assert state.good?
      assert_equal 3, state.offset
      assert_equal '', state.chomped
      assert_nil state.result.value
    end
  end

  def test_keeps_chomped_state_when_parser_fails
    parser = succeed.drop(:integer)

    parser.call(State.new("123a")).tap do |state|
      assert state.bad?
      assert_equal 3, state.offset
      assert_equal "123", state.chomped
      assert_equal "unexpected character", state.result.message
    end
  end

  def test_keeps_results_when_parser_fails
    parser = succeed
      .and_then(:integer)
      .drop(:chomp_if, ->(ch) { ch == ',' })
      .drop(:integer)

    parser.call(State.new("123,456a")).tap do |state|
      assert state.bad?
      assert_equal 7, state.offset
      assert_equal "456", state.chomped
      assert_equal "unexpected character", state.result.message
    end
  end
end
