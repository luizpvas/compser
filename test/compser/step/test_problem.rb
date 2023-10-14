# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestProblem < Minitest::Test
  include Compser

  def test_problem_with_message
    parser = succeed.and_then(:problem, "something went wrong")

    parser.call(Compser::State.new("foo")).tap do |state|
      assert state.bad?
      assert_equal "something went wrong", state.result.message
    end
  end
end
