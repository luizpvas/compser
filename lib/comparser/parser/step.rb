# frozen_string_literal: true

module Comparser::Parser
  class Step < ::Proc
    def take(next_step)
      raise "todo"
    end

    def drop(next_step)
      raise "todo"
    end

    def compose(next_step)
      self >> next_step
    end

    alias _ compose
    alias + take
    alias - drop
  end
end
