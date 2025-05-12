# frozen_string_literal: true

module Compser::SQL
  class Formatter < Visitor
    def self.format(ast)
      formatter = new
      formatter.visit(ast)
      formatter.output.strip
    end

    attr_reader :output

    def initialize
      @output = ""
      @indent = 0
    end

    def visit_select(_node, result_columns, from, where)
      write "SELECT" and newline and indent

      result_columns.map.with_index do |result_column, index|
        visit(result_column)

        if index == result_columns.size - 1
          newline
        else
          write "," and newline
        end
      end

      visit(from)
      visit(where)
    end

    def visit_star(_node)
      write "*"
    end

    def visit_integer(_node, literal)
      write literal.to_s
    end

    def visit_name(_node, name)
      write name
    end

    def visit_alias(_node, result_column, name)
      visit(result_column)
      write " AS "
      visit(name)
    end

    def visit_named_placeholder(_node, name)
      write ":"
      write name
    end

    def visit_positional_placeholder(_node, position)
      write "$"
      write position.to_s
    end

    def visit_from(_node, name, join)
      unindent and write "FROM" and newline and indent
      visit(name) and newline
      visit(join)
    end

    def visit_inner_join(_node, related, left, operator, right)
      unindent and write "INNER JOIN" and newline and indent
      visit(related) and space
      write "ON" and space
      visit(left) and space
      write operator and space
      visit(right) and newline
    end

    def visit_where(_node, expr)
      unindent and write "WHERE" and newline and indent
      visit(expr)
    end

    def visit_expr_binary(_node, left, operator, right)
      visit(left) and space
      write operator and space
      visit(right)
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
