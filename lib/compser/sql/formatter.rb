# frozen_string_literal: true

module Compser::SQL
  module Formatter
    extend self

    AddCommas = ->(results) do
      results.map.with_index do |result, index|
        is_last = index == results.size - 1

        is_last ? result : "#{result},"
      end
    end

    Indent = ->(indent, lines) do
      spaces = " " * indent

      lines.map { spaces + _1 }.join("\n")
    end

    Indent0 = Indent.curry[0]
    Indent2 = Indent.curry[2]

    Format = ->(data) do
      case data
      in [:select, results]
        formatted_results = results.map(&Format).then(&AddCommas)

        Indent0[["SELECT", Indent2[formatted_results]]]
      in [:aliased, result, as]
        Format[result] + " AS " + as
      in [:integer, value]
        value.to_s
      end
    end
  end
end
