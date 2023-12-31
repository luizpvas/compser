# frozen_string_literal: true

class Compser::Step
  DIGIT = /\d/.freeze

  IsDigit = ->(ch) { DIGIT.match?(ch) }

  NotFollowedByAlpha = ->(state) do
    return state if state.eof?
    return state if !state.peek.match?(/[[:alpha:]]/)

    state.bad!("unexpected character")
  end

  Integer = -> do
    Compser::Step.new
      .and_then(:chomp_if, IsDigit)
      .and_then(:chomp_while, IsDigit)
      .and_then(NotFollowedByAlpha)
      .and_then { |state| state.good!(state.consume_chomped.to_i) }
  end
end
