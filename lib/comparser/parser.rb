# frozen_string_literal: true

module Comparser::Parser
  def parse(source_code, parser)
    state = State.new(source_code)

    parser.call(state)

    state.result
  end

  def spaces
    chomp_while(is_good: ->(char) { char == ' ' || char == "\n" || char == "\t" || char == "\r" })
  end

  def one_of(parsers)
    Step.new do |state|
      last_error = nil

      next_state =
        parsers.find do |parser|
          state.savepoint

          parser.call(state)

          if state.good?
            state.commit
            
            state
          else
            last_error = state.result
            state.rollback

            false
          end
        end

      next next_state if next_state

      state.bad!(last_error)
    end
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
