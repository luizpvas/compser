# frozen_string_literal: true

class Compser::Step
  Keywordi = ->(str, state) do
    has_token = state.peek(0, str.size).downcase == str

    if has_token
      str.size.times { state.chomp }

      return state.good!(state.consume_chomped) if state.eof? || !state.peek.match?(/[[:alpha:]]/)
    end

    state.bad!("expected keyword #{str.inspect}")
  end
end
