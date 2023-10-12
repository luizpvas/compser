# frozen_string_literal: true

module Comparser::Parser
  class Step < ::Proc
    def take(next_step)
      compose(next_step) # TODO
    end

    def drop(next_step)
      compose(next_step) # TODO
    end

    def compose(next_step)
      self.class.new do |state|
        next_step.call(self.call(state))
      end
    end

    alias _ compose
    alias + take
    alias - drop
  end
end
