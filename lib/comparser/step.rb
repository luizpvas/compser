# frozen_string_literal: true

class Comparser::Step
  STEPS = {
    integer:     Integer,
    chomp_if:    ChompIf.curry,
    chomp_while: ChompWhile.curry
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
    when Symbol then @steps << STEPS.fetch(args.first).call(*rest)
    when nil    then block ? @steps << block : raise(ArgumentError, "expected a callable") 
    else        raise ArgumentError, "expected a callable"
    end

    self
  end
end
