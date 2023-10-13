# frozen_string_literal: true

class Comparser::Savepoint
  def initialize(state)
    @state = state
    
    @offset = state.offset
    @line = state.line
    @column = state.column
    @chomped = state.chomped
    @result_stack = state.result_stack.dup
  end

  def has_changes?
    @state.offset > @offset
  end

  def rollback_chomped_and_result_stack
    @state.chomped = @chomped
    @state.result_stack = @result_stack.dup
  end

  def rollback
    @state.offset = @offset
    @state.line = @line
    @state.column = @column
    @state.chomped = @chomped
    @state.result_stack = @result_stack.dup
  end
end
