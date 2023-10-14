# frozen_string_literal: true

class Compser::Step
  ChompWhile = ->(predicate, state) do
    state.chomp while !state.eof? && predicate.call(state.peek)

    state
  end
end
