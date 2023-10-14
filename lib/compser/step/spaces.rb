# frozen_string_literal: true

class Compser::Step
  Spaces = -> do
    Compser::Step.new
      .and_then(:chomp_while, ->(c) { c == " " || c == "\t" || c == "\n" || c == "\r" })
  end
end
