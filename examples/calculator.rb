# frozen_string_literal: true

module Calculator
  extend Composer
  extend self

  def evaluate(...)
    expression.parse(...)
  end

  def expression
    take(:one_of, [
      number
    ])
  end

  def sum
    map(->(a, b) { a + b })
      .take(number)
      .drop(:spaces)
      .drop(:token, "+")
      .drop(:spaces)
      .take(:lazy, -> { expression })
  end

  def number
    take(:one_of, [
      map(->(n) { n * -1 }).drop(:token, "-").take(:decimal),
      take(:decimal)
    ])
  end
end
