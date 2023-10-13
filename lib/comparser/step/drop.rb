# frozen_string_literal: true

class Comparser::Step
  Drop = ->(parser, state) do
    savepoint = Comparser::Savepoint.new(state)

    parser.call(state)

    savepoint.rollback_chomped_and_result_stack if state.good?

    state
  end.curry
end
