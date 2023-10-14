# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestSequence < Minitest::Test
  include Compser

  def test_sequence_with_one_iteration
    helper = ->(continue, done) { succeed.and_then(:integer).and_then(done) }
    parser = succeed.and_then(:sequence, helper)

    parser.call(Compser::State.new("1234")).tap do |state|
      assert state.good?
      assert_equal 1234, state.result.value
    end
  end

  def test_sequence_with_multiple_iterations
    integer_then_spaces = ->(continue, done) do
      succeed
        .and_then(:integer)
        .and_then(:one_of, [
          succeed.drop(:chomp_if, ->(ch) { ch == "," }).and_then(continue),
          done
        ])
    end

    parser = map(->(*ints) { ints }).and_then(:sequence, integer_then_spaces)

    parser.call(Compser::State.new("12,23,34")).tap do |state|
      assert state.good?
      assert_equal [12, 23, 34], state.result.value
    end
  end

  def test_sequence_with_multiple_iterations_and_a_failure
    integer_then_spaces = ->(continue, done) do
      succeed
        .and_then(:integer)
        .and_then(:one_of, [
          succeed.drop(:chomp_if, ->(ch) { ch == "," }).and_then(continue),
          done
        ])
    end

    parser = map(->(*ints) { ints }).and_then(:sequence, integer_then_spaces)

    parser.call(Compser::State.new("12,23,34,")).tap do |state|
      assert state.bad?
      assert_equal "unexpected eof", state.result.message
    end
  end

  def test_unbdoung_sequence_reaching_eof
    helper = ->(continue, done) { succeed.and_then(:chomp_if, ->(_) { true }).and_then(continue) }
    parser = succeed.and_then(:sequence, helper)

    parser.call(Compser::State.new("1234")).tap do |state|
      assert state.bad?
      assert_equal "unexpected eof", state.result.message
    end
  end
end
