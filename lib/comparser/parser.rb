# frozen_string_literal: true

module Comparser::Parser
  def parse(source_code, parser)
    state = State.new(source_code)

    parser.call(state)

    state.result
  end

  def and_then(to_value:)
    Step.new do |state|
      next to_value.(state) if state.good?

      state
    end
  end

  def chomp_if(error_message:, is_good:)
    Step.new do |state|
      if is_good.call(state.peek)
        state.chomp

        next state
      end

      state.bad!(error_message)
    end
  end

  def chomp_while(is_good:)
    Step.new do |state|
      while !state.eof? && is_good.call(state.peek)
        state.chomp
      end

      state
    end
  end
end
