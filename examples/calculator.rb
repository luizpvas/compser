# frozen_string_literal: true

require_relative "../lib/compser"

module Compser::Calculator
  extend Compser
  extend self

  def evaluate(...)
    expression.parse(...)
  end

  OPERATORS = {
    "+" => ->(a, b) { a + b },
    "-" => ->(a, b) { a - b },
    "*" => ->(a, b) { a * b },
    "/" => ->(a, b) { a / b }
  }.freeze

  Evaluate = ->(*args) {
    result = args.shift

    while args.any?
      oprt = args.shift
      expr = args.shift

      result = OPERATORS.fetch(oprt).call(result, expr)
    end

    result
  }

  ExpressionHelper = ->(continue, done) do
    take(:one_of, [
      take(operator).drop(:spaces).take(value).drop(:spaces).and_then(continue),
      done
    ])
  end

  def expression
    map(Evaluate)
      .take(value)
      .drop(:spaces)
      .take(:sequence, ExpressionHelper)
  end

  def value
    take(:one_of, [
      drop(:token, "(").drop(:spaces).take(:lazy, -> { expression }).drop(:spaces).drop(:token, ")"),
      number
    ])
  end

  def operator
    take(:chomp_if, ->(c) { OPERATORS.key?(c) })
      .and_then { |state| state.good!(state.consume_chomped) }
  end

  def number
    take(:one_of, [
      map(->(n) { n * -1 }).drop(:token, "-").take(:decimal),
      take(:decimal)
    ])
  end
end

calc = ->(input) { input + " = " + sprintf("%.2f", Compser::Calculator.evaluate(input).value) }

puts calc.("1 + 1")
puts calc.("1 + 2 + 3")
puts calc.("3 * 3 / 2")
puts calc.("0.1 + 0.2")
puts calc.("2 + 2 * 4")
puts calc.("(2 + 2) * 4")
puts calc.("((((10))))")
puts calc.("((((10))+5))")
