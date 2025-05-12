# frozen_string_literal: true

module Compser::SQL
  class Formatter
    def self.format(ast)
      formatter = new
      formatter.call(ast)
      formatter.output.strip
    end

    attr_reader :output

    def initialize
      @output = ""
      @indent = 0
    end

    def call(term)
      case term
      in [:select, result_columns, from, where]
        write "SELECT" and newline and indent

        result_columns.map.with_index do |result_column, index|
          call(result_column)

          if index == result_columns.size - 1
            newline
          else
            write "," and newline
          end
        end

        call(from)
        call(where)

      in :star
        write "*"

      in [:integer, literal]
        write literal.to_s

      in [:name, name]
        write name
      
      in [:alias, result, name]
        call(result) and write " AS " and call(name)

      in [:named_placeholder, name]
        write ":" and write name

      in [:from, name, join]
        unindent and write "FROM" and newline and indent
        call(name) and newline
        call(join)

      in [:inner_join, related, left, operator, right]
        unindent and write "INNER JOIN" and newline and indent
        call(related) and space
        write "ON" and space
        call(left) and space
        write operator and space
        call(right) and newline

      in [:where, expr]
        unindent and write "WHERE" and newline and indent
        call(expr)

      in [:expr_binary, left, operator, right]
        call(left) and space
        write operator and space
        call(right)

      in nil
        nil
      end
    end

    private

    def write(str)
      if @output.end_with?("\n")
        @output += (" " * @indent) + str
      else
        @output += str
      end
    end

    def newline
      @output += "\n"
    end

    def space
      @output += " "
    end

    def indent
      @indent += 2
    end

    def unindent
      @indent -= 2
    end
  end
end
