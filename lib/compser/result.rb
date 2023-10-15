# frozen_string_literal: true

module Compser::Result
  Good = Data.define(:value) do
    def good? = true
    def bad?  = false
  end

  Bad = Data.define(:message) do
    def bad?  = true
    def good? = false
  end
end
