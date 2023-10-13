# frozen_string_literal: true

class Comparser::Step
  Token = ->(str, state) do
    has_token = state.peek(0, str.size) == str

    if has_token
      str.size.times { state.chomp }

      return state.good!(str)
    end

    state.bad!("expected #{str.inspect}")
  end
end
