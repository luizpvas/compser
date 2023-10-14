# frozen_string_literal: true

require "bigdecimal"

class Compser::Step
  Decimal = -> do
    Compser::Step.new
      .and_then(:chomp_if, IsDigit)
      .and_then(:chomp_while, IsDigit)
      .and_then(:one_of, [
        Compser::Step.new
          .and_then(:chomp_if, ->(ch) { ch == "." })
          .and_then(:chomp_if, IsDigit)
          .and_then(:chomp_while, IsDigit),
        Compser::Step.new
      ])
      .and_then(NotFollowedByAlpha)
      .and_then { |state| state.good!(BigDecimal(state.consume_chomped)) }
  end
end
