# frozen_string_literal: true

class Comparser::Step
  Sequence = ->(helper, state) do
    continue = ->(state) { state.good!(:continue) }
    done = ->(state) { state.good!(:done) }

    state = helper.call(continue, done).call(state)
    while !state.eof? && state.good? && state.result.value == :continue
      puts state.result.inspect

      state.pop_results(1)

      state = helper.call(continue, done).call(state)
    end

    puts state.result.inspect

    if state.good? && state.result.value == :done
      state.pop_results(1)
      
      return state
    end

    state.bad!("unbound sequence")
  end
end