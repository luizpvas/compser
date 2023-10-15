# frozen_string_literal: true

class Compser::Step
  OneOf = ->(branches, state) do
    return state.bad!(":one_of requires at least one branch") if branches.empty?

    savepoint = Compser::Savepoint.new(state)
    
    branches.each_with_index do |branch, index|
      state = branch.call(state)

      return if savepoint.has_changes?
      return if index == branches.size - 1 # is last

      savepoint.rollback
    end

    state.bad!(":one_of failed all branches")
  end
end
