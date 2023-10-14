# frozen_string_literal: true

class Comparser::Step
  Problem = ->(message, state) do
    state.bad!(message)
  end
end
