# frozen_string_literal: true

class Comparser::Step
  ChompIf = ->(predicate, state) do
    return state.bad!("unexpected eof") if state.eof?

    return state.chomp if predicate.call(state.peek)

    state.bad!("unexpected character")
  end
end
