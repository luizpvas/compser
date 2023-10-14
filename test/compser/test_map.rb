# frozen_string_literal: true

require "test_helper"

class Compser::TestMap < Minitest::Test
  include Compser

  def test_map_with_with_no_results
    parser = map(->{ "foo" })
    
    parser.call(State.new("bar")).tap do |state|
      assert state.good?
      assert_equal "foo", state.result.value
    end
  end

  def test_map_with_one_result
    parser = map(->(x) { x + 1 })
      .and_then { |state| state.good!(1) }

    parser.call(State.new("")).tap do |state|
      assert state.good?
      assert_equal 2, state.result.value
    end
  end

  def test_map_with_multiple_results
    parser = map(->(x, y) { x + y })
      .and_then { |state| state.good!(1) }
      .and_then { |state| state.good!(2) }

    parser.call(State.new("")).tap do |state|
      assert state.good?
      assert_equal 3, state.result.value
    end
  end

  def test_map_with_bad_state
    parser = map(->{ "foo" })

    parser.call(State.new(nil).bad!("something went wrong")).tap do |state|
      assert state.bad?
      assert_equal "something went wrong", state.result.message
    end
  end
end
