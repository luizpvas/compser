# frozen_string_literal: true

class Comparser::Step
  ChompIf = ->(predicate, state) do
    return state.chomp if predicate.call(state.peek)

    state.bad!("unexpected character")
  end
end
