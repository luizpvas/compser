# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestOneOf < Minitest::Test
  include Compser

  def test_one_of_branchless
    parser = succeed.and_then(:one_of, [])

    parser.call(State.new("foo")).tap do |state|
      assert state.bad?
      assert_equal "", state.chomped
      assert_equal ":one_of requires at least one branch", state.result.message
    end
  end

  def test_one_of_succeeds_first_branch
    parser = succeed.and_then(:one_of, [
      ->(state) { state.good!("foo") },
      ->(state) { state.good!("bar") },
    ])

    parser.call(State.new(nil)).tap do |state|
      assert state.good?
      assert_equal "foo", state.result.value
    end
  end

  def test_one_of_succeeds_second_branch
    parser = succeed.and_then(:one_of, [
      ->(state) { state.bad!("foo") },
      ->(state) { state.good!("bar") },
    ])

    parser.call(State.new(nil)).tap do |state|
      assert state.good?
      assert_equal "bar", state.result.value
    end
  end

  def test_one_of_commits_to_branch_that_succeeds
    parser = succeed.and_then(:one_of, [
      succeed.and_then(:spaces).and_then(->(state) { state.bad!("foo") }),
      ->(state) { state.good!("bar") },
    ])

    parser.call(State.new(" ")).tap do |state|
      assert state.bad?
      assert_equal "foo", state.result.message
    end
  end
end
