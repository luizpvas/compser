# frozen_string_literal: true

module Comparser::Parser
  class Step < ::Proc
    def +(next_step)
      raise "todo"
    end

    def -(next_step)
      raise "todo"
    end

    def _(next_step)
      self >> next_step
    end
  end
end
