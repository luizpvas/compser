# frozen_string_literal: true

class Comparser::Step
  Sequence = ->(helper, state) do
    state.__sequence__ = nil

    continue = ->(state) { state.__sequence__ = :continue; state }
    done     = ->(state) { state.__sequence__ = :done; state }

    state = helper.call(continue, done).call(state)

    while state.good? && state.__sequence__ == :continue
      state = helper.call(continue, done).call(state)
    end

    return state if state.bad?

    if state.good? && state.__sequence__ == :done
      return state
    end

    state.bad!("unbound sequence")
  end
end
