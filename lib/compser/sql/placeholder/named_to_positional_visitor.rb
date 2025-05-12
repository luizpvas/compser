# frozen_string_literal: true

module Compser::SQL::Placeholder
  class NamedToPositionalVisitor < ::Compser::SQL::Visitor
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
end
