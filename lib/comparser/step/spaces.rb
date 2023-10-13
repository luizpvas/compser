# frozen_string_literal: true

class Comparser::Step
  Spaces = -> do
    Comparser::Step.new
      .and_then(:chomp_while, ->(c) { c == " " || c == "\t" || c == "\n" || c == "\r" })
  end
end
