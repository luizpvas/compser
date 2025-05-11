# frozen_string_literal: true

module Compser::SQL
  module Parser
    extend self
    include ::Compser

    def parse(text)
      select.parse(text)
    end

    def debug(text)
      ::Compser::State.new(text).tap { select.call(_1) }
    end

    def select
      map(->(results, from) { [:select, results, from] })
        .drop(:keywordi, "select")
        .drop(:spaces)
        .take(results)
        .drop(:spaces)
        .take(:one_of, [ from, -> { _1.good!(nil) } ])
    end

    def results
      map(->(*args) { args })
        .take(:sequence, ->(continue, done) do
          result
            .drop(:spaces)
            .take(:one_of, [
              drop(:token, ",").drop(:spaces).and_then(continue),
              done
            ])
        end)
    end

    def result
      map(->(result, as) { as.nil? ? result : [:aliased, result, as] })
        .take(:one_of, [ integer, name ])
        .drop(:spaces)
        .take(:one_of, [
          drop(:keywordi, "as").drop(:spaces).take(name),
          ->(state) { state.good!(nil) }
        ])
    end

    def from
      map(->(name) { [:from, name] })
        .drop(:keywordi, "from")
        .drop(:spaces)
        .take(name)
        .drop(:spaces)
    end

    def integer
      map(->(value) { [:integer, value] })
        .take(:integer)
    end

    IsChar = ->(c) { c.match?(/[a-zA-Z_]/) }
    IsAlpha = ->(c) { c.match?(/[a-zA-Z0-9_\.]/) }

    def name
      map(->(name) { [:name, name] })
        .and_then(:chomp_if, IsChar)
        .and_then(:chomp_while, IsAlpha)
        .and_then { |state| state.good!(state.consume_chomped) }
    end
  end
end
