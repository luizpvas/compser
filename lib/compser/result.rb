# frozen_string_literal: true

module Compser::Result
  Good = Data.define(:state, :value) do
    def good? = true
    def bad?  = false
  end

  Bad = Data.define(:state, :message) do
    def bad?  = true
    def good? = false
  end
end
