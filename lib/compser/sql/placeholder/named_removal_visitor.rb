# frozen_string_literal: true

module Compser::SQL::Placeholder
  class NamedRemovalVisitor < ::Compser::SQL::Visitor
    def initialize(named_placeholders_to_remove)
      @named_placeholders_to_remove = named_placeholders_to_remove
    end

    def visit_where(node, expr)
      visit(expr)

      node.clear if expr.empty?
    end

    def visit_expr_binary(node, left, operator, right)
      puts "BEFORE"
      puts node.inspect

      visit(left)
      visit(right)

      return if !left.empty? && !right.empty?

      if removable_operator?(operator)
        puts "REMOVABLE OPERATOR"
        puts left.inspect
        puts operator
        puts right.inspect
        puts node.inspect

        node.clear
      elsif liftable_operator?(operator)
        puts "LIFTABLE OPERATOR"
        puts left.inspect
        puts operator
        puts right.inspect
        puts node.inspect

        node.clear
        node.replace(left)  if right.empty?
        node.replace(right) if left.empty?
      end

      puts "AFTER"
      puts node.inspect
    end

    def visit_named_placeholder(node, name)
      if @named_placeholders_to_remove.include?(name)
        node.clear
      end
    end

    private

    def removable_operator?(operator)
      ["=", ">", ">=", "<", "<=", "<>", "like", "ilike", "~"].include?(operator)
    end

    def liftable_operator?(operator)
      ["AND", "OR"].include?(operator)
    end
  end
end
