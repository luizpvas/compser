# frozen_string_literal: true

module Compser::SQL
  module Parser
    extend self
    include ::Compser

    def parse(text)
      expression.parse(text)
    end

    def expression
      select
    end

    CommaSeparatedResultColumn = ->(continue, done) do
      result_column
        .drop(:spaces)
        .take(:one_of, [
          drop(:token, ",").drop(:spaces).and_then(continue),
          done
        ])
    end

    def select
      map(->(*result_columns) { [:select, result_columns] })
        .drop(:keywordi, "select")
        .drop(:spaces)
        .take(:sequence, CommaSeparatedResultColumn)
    end

    def result_column
      take(:one_of, [ integer ])
    end

    IsChar = ->(c) { c.match?(/[a-zA-Z]/) }
    IsAlpha = ->(c) { c.match?(/[[:alpha:]]/) }

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
