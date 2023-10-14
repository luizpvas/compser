# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestToken < Minitest::Test
  include Compser

  def test_token_with_one_character
    parser = succeed.and_then(:token, "a")

    parser.call(Compser::State.new("a")).tap do |state|
      assert state.good?
      assert_equal "a", state.result.value
    end
  end

  def test_token_with_multiple_characters
    parser = succeed.and_then(:token, "foo")

    parser.call(Compser::State.new("foo")).tap do |state|
      assert state.good?
      assert_equal "foo", state.result.value
    end
  end
  
  def test_token_with_trailing_characters
    parser = succeed.and_then(:token, "foo")

    parser.call(Compser::State.new("foobar")).tap do |state|
      assert state.good?
      assert_equal "foo", state.result.value
    end
  end

  def test_token_mismatch_casing
    parser = succeed.and_then(:token, "foo")

    parser.call(Compser::State.new("FOO")).tap do |state|
      assert state.bad?
      assert_equal "expected \"foo\"", state.result.message
    end
  end

  def test_token_mismatch_last_character
    parser = succeed.and_then(:token, "foo")

    parser.call(Compser::State.new("fo")).tap do |state|
      assert state.bad?
      assert_equal "expected \"foo\"", state.result.message
    end
  end
end
