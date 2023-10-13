# frozen_string_literal: true

class Comparser::Step
  STEPS = {
    chomp_if:    ChompIf.curry,
    chomp_while: ChompWhile.curry,
    decimal:     Decimal,
    integer:     Integer,
    one_of:      OneOf.curry,
    spaces:      Spaces
  }.freeze

  def initialize(mapper = nil)
    @mapper = mapper
    @steps   = []
  end

  def call(state)
    results_before = state.result_stack.size
  
    state = @steps.reduce(state) do |state, step|
      return state if state.bad?

      step.call(state)
    end

    results_after = state.result_stack.size

    if @mapper.present? && state.good?
      args = state.pop_results(results_after - results_before).map(&:value)

      state.good!(@mapper.call(*args))
    end

    state
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
