# frozen_string_literal: true

module Compser::SQL
  module Parser
    extend self
    include ::Compser

    def parse(text)
      select.parse(text)
    end

    def select
      map(->(*results) { [:select, results] })
        .drop(:keywordi, "select")
        .drop(:spaces)
        .take(:sequence, CommaSeparatedResults)
    end

    CommaSeparatedResults = ->(continue, done) do
      result
        .drop(:spaces)
        .take(:one_of, [
          drop(:token, ",").drop(:spaces).and_then(continue),
          done
        ])
    end

    def result
      map(->(result, as) { as.nil? ? result : [:aliased, result, as] })
        .take(:one_of, [ integer ])
        .drop(:spaces)
        .take(:one_of, [
          drop(:keywordi, "as").drop(:spaces).take(name),
          ->(state) { state.good!(nil) }
        ])
    end

    IsChar = ->(c) { c.match?(/[a-zA-Z]/) }
    IsAlpha = ->(c) { c.match?(/[a-zA-Z0-9]/) }

    def name
      succeed
        .and_then(:chomp_if, IsChar)
        .and_then(:chomp_while, IsAlpha)
        .and_then { |state| state.good!(state.consume_chomped) }
    end

    def integer
      map(->(value) { [:integer, value] })
        .take(:integer)
    end
  end
end
