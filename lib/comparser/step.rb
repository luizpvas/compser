# frozen_string_literal: true

class Comparser::Step
  ChompIf = ->(predicate, state) do
    return state.chomp if predicate.call(state.peek)

    state.bad!("unexpected character")
  end

  CHAIN_METHODS = {
    chomp_if: ChompIf.curry
  }.freeze

  def initialize
    @steps = []
  end

  def call(state)
    @steps.reduce(state) do |state, step|
      return state if state.bad?

      step.call(state)
    end
  end

  def and_then(*args, &block)
    first, *rest = args

    case args.first
    when Proc   then @steps << args.first
    when Symbol then @steps << CHAIN_METHODS.fetch(args.first).call(*rest)
    when nil    then block ? @steps << block : raise(ArgumentError, "expected a callable") 
    else        raise ArgumentError, "expected a callable"
    end

    self
  end
end
