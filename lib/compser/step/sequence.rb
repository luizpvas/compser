# frozen_string_literal: true

class Compser::Step
  CONT = :continue
  DONE = :done

  Sequence = ->(helper, state) do
    state.__sequence__ = nil

    continue = ->(state) { state.__sequence__ = CONT; state }
    done     = ->(state) { state.__sequence__ = DONE; state }

    state = helper.call(continue, done).call(state)

    while state.good? && state.__sequence__ == CONT
      state = helper.call(continue, done).call(state)
    end

    return state if state.bad?

    if state.good? && state.__sequence__ == DONE
      return state
    end

    state.bad!("unbound sequence")
  end
end
