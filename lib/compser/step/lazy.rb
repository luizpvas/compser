# frozen_string_literal: true

class Compser::Step
  Lazy = ->(to_parser, state) do
    to_parser.call.call(state)

    state
  end
end
