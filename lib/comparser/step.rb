# frozen_string_literal: true

class Comparser::Step
  def initialize
    @steps = []
  end

  def call(state)
    @steps.reduce(state) { |state, step| step.call(state) }
  end

  def and_then(*args, &block)
    case args.first
    when Proc then @steps << args.first
    when nil  then block ? @steps << block : raise(ArgumentError, "expected a callable") 
    else raise ArgumentError, "expected a callable"
    end

    self
  end
end
