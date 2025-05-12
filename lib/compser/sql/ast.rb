# frozen_string_literal: true

module Compser::SQL
  class AST
    def initialize(ast)
      @ast = ast
    end

    def format
      ::Compser::SQL::Formatter.format(@ast)
    end

    def replace_named_placeholders_with_positional_placeholders!
      NamedPlaceholderToPositionalPlaceholderVisitor.new.then do |visitor|
        visitor.visit(@ast)

        visitor.positional_placeholders
      end
    end
  end
end
