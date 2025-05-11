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
      in [:select, results, from]
        write "SELECT" and newline and indent

        results.map.with_index do |result, index|
          call(result)

          if index == results.size - 1
            newline
          else
            write "," and newline
          end
        end

        call(from)

      in [:integer, literal]
        write literal.to_s

      in [:name, name]
        write name
      
      in [:aliased, result, name]
        call(result)
        write " AS "
        call(name)

      in [:from, name]
        unindent and write "FROM" and newline and indent
        call(name)

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

    def indent
      @indent += 2
    end

    def unindent
      @indent -= 2
    end
  end
end
