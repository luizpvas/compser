# frozen_string_literal: true

module Compser::SQL::Placeholder
  class NamedDetectionVisitor < ::Compser::SQL::Visitor
    attr_reader :named_placeholders

    def initialize
      @named_placeholders = []
    end

    def visit_named_placeholder(_node, name)
      @named_placeholders << name if !@named_placeholders.include?(name)
    end
  end
end
