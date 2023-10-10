# frozen_string_literal: true

module Comparser::Parser
  class Step < ::Proc
    def +(next_step)
      raise "todo"
    end

    def _(next_step)
      raise "todo"
    end
  end
end
