# frozen_string_literal: true

require_relative "../lib/compser"

module Calculator
  extend Compser
  extend self

  def evaluate(...)
    expression.parse(...)
  end

  def expression
    take(:one_of, [
      backtrack(operation),
      number
    ])
  end

  OPERATORS = {
    "+" => ->(a, b) { a + b },
    "-" => ->(a, b) { a - b }
  }.freeze

  Evaluate = ->(a, op, b) { OPERATORS.fetch(op).call(a, b) }

  def operation
    map(Evaluate)
      .take(number)
      .drop(:spaces)
      .take(:one_of, [
        take(:token, "+")
          .drop(:spaces)
          .take(:lazy, -> { expression }),
        take(:token, "-")
          .drop(:spaces)
          .take(:lazy, -> { expression })
      ])
  end

  def number
    take(:one_of, [
      map(->(n) { n * -1 }).drop(:token, "-").take(:decimal),
      take(:decimal)
    ])
  end
end

puts Calculator.evaluate("10 + 10").value.to_s
