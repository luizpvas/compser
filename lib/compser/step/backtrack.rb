# frozen_string_literal: true

class Compser::Step
  Backtrack = ->(parser, state) do
    savepoint = Compser::Savepoint.new(state)
    
    parser.call(state)

    savepoint.rollback if state.bad?

    state
  end
end
