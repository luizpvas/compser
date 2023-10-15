# frozen_string_literal: true

class Compser::Step
  STEPS = {
    chomp_if:             ChompIf.curry,
    chomp_while:          ChompWhile.curry,
    decimal:              Decimal,
    double_quoted_string: DoubleQuotedString,
    integer:              Integer,
    keyword:              Keyword.curry,
    lazy:                 Lazy.curry,
    one_of:               OneOf.curry,
    problem:              Problem.curry,
    sequence:             Sequence.curry,
    spaces:               Spaces,
    token:                Token.curry
  }.freeze

  def initialize(mapper = nil)
    @mapper = mapper
    @steps   = []
  end

  def parse(src)
    call(Compser::State.new(src)).result
  end

  def call(state)
    results_before = state.result_stack.size
  
    @steps.each do |step|
      return state if state.bad?

      step.call(state)
    end

    results_after = state.result_stack.size

    if @mapper && state.good?
      args = state.pop_results(results_after - results_before).map(&:value)

      state.good!(@mapper.call(*args))
    end

    state
  end

  def and_then(*args, &block)
    first, *rest = args

    step =
      case first
      when Proc          then first
      when Compser::Step then first
      when Symbol        then STEPS.fetch(args.first).call(*rest)
      when nil           then block ? block : raise(ArgumentError, "expected a callable") 
      else               raise ArgumentError, "expected a callable, got #{args.inspect}"
      end

    @steps << step

    self
  end

  alias take and_then

  def drop(*args, &block)
    first, *rest = args

    step =
      case first
      when Proc          then Drop.(first)
      when Compser::Step then Drop.(first)
      when Symbol        then Drop.(STEPS.fetch(first).call(*rest))
      when nil           then block ? Drop.(block) : raise(ArgumentError, "expected a callable") 
      else               raise ArgumentError, "expected a callable"
      end

    @steps << step

    self
  end
end
