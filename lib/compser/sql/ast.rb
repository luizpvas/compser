# frozen_string_literal: true

module Compser::SQL
  class AST
    def initialize(ast)
      @ast = ast
    end

    def format
      ::Compser::SQL::Formatter.format(@ast)
    end

    class NamedPlaceholderToPositionalPlaceholderVisitor < Visitor
      attr_reader :positional_placeholders

      def initialize
        @positional_placeholders = {}
      end

      def visit_named_placeholder(node, name)
        position = @positional_placeholders[name]

        if position.nil?
          position = @positional_placeholders.size + 1
          @positional_placeholders[name] = position
        end

        node.clear
        node[0] = :positional_placeholder
        node[1] = position
      end
    end

    def replace_named_placeholders_with_positional_placeholders!
      NamedPlaceholderToPositionalPlaceholderVisitor.new.then do |visitor|
        visitor.visit(@ast)

        visitor.positional_placeholders
      end
    end
  end
end
