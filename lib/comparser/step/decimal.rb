# frozen_string_literal: true

require "bigdecimal"

class Comparser::Step
  Decimal = -> do
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
      .and_then { |state| state.good!(BigDecimal(state.consume_chomped)) }
  end
end
