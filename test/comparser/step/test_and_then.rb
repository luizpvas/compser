# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestAndThen < Minitest::Test
  include Comparser

  def test_and_then_with_identity_function
    parser = succeed.and_then(->(state) { state })

    assert_equal 10, parser.call(10)
  end

  def test_and_then_with_transformation
    parser = succeed.and_then(->(state) { state + 1 })

    assert_equal 11, parser.call(10)
  end

  def test_and_then_with_multiple_transformations
    parser = succeed
      .and_then(->(state) { state + [1] })
      .and_then(->(state) { state + [2] })

    assert_equal [1, 2], parser.call([])
  end

  def test_and_then_with_block
    parser = succeed
      .and_then { |state| state + [1] }
      .and_then { |state| state + [2] }

    assert_equal [1, 2], parser.call([])
  end

  def test_and_then_without_callable
    parser = succeed

    assert_raises(ArgumentError) { parser.and_then }
    assert_raises(ArgumentError) { parser.and_then("foo") }
  end
end
