# frozen_string_literal: true

class Compser::Step
  ChompWhile = ->(predicate, state) do
    while !state.eof? && predicate.call(state.peek)
      state.chomp
    end
  end
end
