# frozen_string_literal: true

class Compser::Step
  Keyword = ->(str, state) do
    has_token = state.peek(0, str.size) == str

    if has_token
      str.size.times { state.chomp }

      return state.good!(str) if state.eof? || !state.peek.match?(/[[:alpha:]]/)
    end

    state.bad!("expected keyword #{str.inspect}")
  end
end
