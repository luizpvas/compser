# frozen_string_literal: true

module Comparser::Parser
  def parse(source_code, parser)
    state = State.new(source_code)

    parser.call(state)

    state.result
  end

  def chomp_if(error_message:, is_good:)
    Step.new do |state|
      if is_good.call(state.peek)
        next state.chomp
      end

      state.bad(error_message)
    end
  end

  def chomp_while(&is_good)
    Step.new do |state|
    end
  end
end
