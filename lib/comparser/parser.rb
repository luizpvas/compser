# frozen_string_literal: true

module Comparser::Parser
  def parse(source_code, parser)
    state = State.new(source_code)

    parser.call(state)

    state.result
  end

  IsDigit  = ->(ch) { ch.match?(/[0-9]/) }
  IsAlpha  = ->(ch) { ch.match?(/[a-zA-Z]/) }
  NotAlpha = ->(ch) { ch.nil? || !IsAlpha[ch] }

  def integer
    chomp_if(is_good: IsDigit, error_message: "expected digit")
      .>> chomp_while(is_good: IsDigit)
      .>> assert_peek(is_good: NotAlpha, error_message: "unexpected character")
      .>> and_then(to_value: ->(state) { state.good!(state.consume_chomped.to_i) })
  end

  def keyword(str)
    Step.new do |state|
      keyword_under_cursor = state.peek(0, str.length) == str
      followed_by_non_alpha = NotAlpha[state.peek(str.length)]

      if keyword_under_cursor && followed_by_non_alpha
        str.length.times { state.chomp }

        next state.good!(state.consume_chomped)
      end

      state.bad!("expected keyword #{str.inspect}")
    end
  end

  def symbol(str)
    Step.new do |state|
      if state.peek(0, str.length) == str
        str.length.times { state.chomp }

        next state.good!(state.consume_chomped)
      end

      state.bad!("expected symbol #{str.inspect}")
    end
  end

  def spaces
    chomp_while(is_good: ->(char) { char == " " || char == "\n" || char == "\t" || char == "\r" })
  end

  def succeed
    Step.new { _1 }
  end

  def map(to_value, &block)
    Step.new do |state|
      next state if state.bad?

      remember_result_stack_size = state.result_stack.size
      resolved_parser = block.call

      resolved_parser.call(state)

      if state.good?
        results = state.pop_results(state.result_stack.size - remember_result_stack_size)
        values = results.map(&:value)

        mapped_value =
          if to_value.respond_to?(:call)
            to_value.call(*values)
          elsif to_value.respond_to?(:new)
            to_value.new(*values)
          else
            to_value
          end

        next state.good!(mapped_value)
      end

      state
    end
  end

  def one_of(parsers)
    Step.new do |state|
      last_error = nil

      next_state =
        parsers.find do |parser|
          savepoint = Savepoint.new(state)

          parser.call(state)

          if state.good? || savepoint.has_changes?    
            state
          else
            last_error = state.result
            savepoint.rollback

            false
          end
        end

      next next_state if next_state

      state.bad!(last_error)
    end
  end

  def lazy(parser)
    Step.new do |state|
      next state if state.bad?

      parser.call.call(state)
    end
  end

  def debug
    and_then(to_value: ->(state) {
      puts({
        good?: state.good?,
        chomped: state.chomped,
        peek: state.peek,
        result_stack: state.result_stack.map(&:value),
      }.inspect)

      state
    })
  end

  def and_then(to_value:)
    Step.new do |state|
      next to_value.(state) if state.good?

      state
    end
  end

  def assert_peek(is_good:, error_message:)
    and_then(to_value: ->(state) {
      return state.bad!(error_message) if !is_good.call(state.peek)

      state
    })
  end

  def chomp_if(error_message:, is_good:)
    Step.new do |state|
      next state if state.bad?

      if is_good.call(state.peek)
        state.chomp

        next state
      end

      state.bad!(error_message)
    end
  end

  def chomp_while(is_good:)
    Step.new do |state|
      next state if state.bad?

      while !state.eof? && is_good.call(state.peek)
        state.chomp
      end

      state
    end
  end
end
