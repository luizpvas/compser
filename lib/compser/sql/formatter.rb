# frozen_string_literal: true

module Compser::SQL
  module Formatter
    extend self

    Indent = ->(indent, lines) do
      spaces = " " * indent

      lines.map { spaces + _1 }.join("\n")
    end

    Indent0 = Indent.curry[0]
    Indent2 = Indent.curry[2]

    Format = ->(data) do
      case data
      in [:select, columns]
        formatted_columns = columns.map(&Format)

        Indent0[["SELECT", Indent2[formatted_columns]]]
      in [:integer, value]
        value.to_s
      end
    end
  end
end
