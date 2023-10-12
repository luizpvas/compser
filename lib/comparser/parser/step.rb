# frozen_string_literal: true

module Comparser::Parser
  class Step < Proc
    attr_reader :name

    def initialize(name = nil)
      @name = name
    end
    
    def drop(next_step)
      next_step_with_drop = self.class.new do |state|
        savepoint = Savepoint.new(state)

        next_step.call(state)
        
        savepoint.rollback_chomped_and_result_stack if state.good?

        state
      end

      compose(next_step_with_drop)
    end

    def compose(next_step)
      self.class.new do |state|
        next_step.call(self.call(state))
      end
    end

    alias >> compose
    alias + compose
    alias - drop
  end
end
