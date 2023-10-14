# frozen_string_literal: true

class Compser::Step
  Problem = ->(message, state) do
    state.bad!(message)
  end
end
