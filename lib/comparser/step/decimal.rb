# frozen_string_literal: true

require "bigdecimal"

class Comparser::Step
  DecimalHelper = -> do
    Comparser::Step.new
      .and_then(:chomp_if, IsDigit)
      .and_then(:chomp_while, IsDigit)
      .and_then(:one_of, [
        Comparser::Step.new
          .and_then(:chomp_if, ->(ch) { ch == "." })
          .and_then(:chomp_if, IsDigit)
          .and_then(:chomp_while, IsDigit),
        Comparser::Step.new
      ])
      .and_then(NotFollowedByAlpha)
  end
  
  Decimal = -> do
    Comparser::Step.new
      .and_then(:one_of, [
        Comparser::Step.new
          .drop(:token, "-")
          .and_then(DecimalHelper.())
          .and_then { |state| state.good!(BigDecimal(state.consume_chomped) * -1) },
        DecimalHelper.()
          .and_then { |state| state.good!(BigDecimal(state.consume_chomped)) },
        Comparser::Step.new
          .and_then(:problem, "unexpected character")
      ])
  end
end
