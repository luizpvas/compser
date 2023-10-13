# frozen_string_literal: true

require "test_helper"

class Comparser::Step::TestSequence < Minitest::Test
  include Comparser

  def test_sequence_with_one_iteration
    helper = ->(continue, done) { succeed.and_then(:integer).and_then(done) }
    parser = succeed.and_then(:sequence, helper)

    parser.call(Comparser::State.new("1234")).tap do |state|
      assert state.good?
      assert_equal 1234, state.result.value
    end
  end

  def test_sequence_with_multiple_iterations
    integer_then_spaces = ->(continue, done) do
      succeed
        .and_then(:integer)
        .and_then(:one_of, [
          succeed.and_then(:spaces).and_then(continue),
          succeed.and_then(done)
        ])
    end

    parser = map(->(*ints) { ints }).and_then(:sequence, integer_then_spaces)

    parser.call(Comparser::State.new("12 23 34")).tap do |state|
      assert state.good?
      assert_equal [12, 23, 34], state.result.value
    end
  end
end
