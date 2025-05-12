# frozen_string_literal: true

module Compser::SQL
  class Visitor
    def visit(ast)
      return if ast.nil?

      tag, *args = ast

      return if tag.nil?

      send("visit_#{tag}", *[ast, *args])
    end

    def visit_select(_node, result_columns, from, where)
      result_columns.each do |result_column|
        visit(result_column)
      end

      visit(from) if from
      visit(where) if where
    end

    def visit_star(_node)
      nil
    end

    def visit_integer(_node, literal)
      nil
    end

    def visit_name(_node, name)
      nil
    end

    def visit_alias(_node, result_column, name)
      visit(result_column)
    end

    def visit_named_placeholder(_node, name)
      nil
    end

    def visit_positional_placeholder(_node, position)
      nil
    end

    def visit_from(_node, name, join)
      visit(name)
      visit(join)
    end

    def visit_inner_join(_node, related, left, operator, right)
      visit(related)
      visit(left)
      visit(right)
    end

    def visit_where(_node, expr)
      visit(expr)
    end

    def visit_expr_binary(_node, left, operator, right)
      visit(left)
      visit(right)
    end
  end
end
