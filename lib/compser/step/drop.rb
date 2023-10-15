# frozen_string_literal: true

class Compser::Step
  Drop = ->(parser, state) do
    savepoint = Compser::Savepoint.new(state)

    parser.call(state)

    savepoint.rollback_chomped_and_result_stack if state.good?
  end.curry
end
