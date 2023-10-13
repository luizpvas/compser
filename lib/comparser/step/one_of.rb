# frozen_string_literal: true

class Comparser::Step
  OneOf = ->(branches, state) do
    return state.bad!(":one_of requires at least one branch") if branches.empty?

    savepoint = Comparser::Savepoint.new(state)
    
    branches.each do |branch|
      state = branch.call(state)

      return state if state.good? || savepoint.has_changes?

      savepoint.rollback
    end

    state.bad!(":one_of failed all branches")
  end
end
