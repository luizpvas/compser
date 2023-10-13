# frozen_string_literal: true

class Comparser::Step
  DoubleQuotedStringHelper = ->(continue, done) do
    Comparser::Step.new
      .and_then(:one_of, [
        Comparser::Step.new
          .and_then(:chomp_if, ->(ch) { ch == "\\" })
          .and_then(:chomp_if, ->(_) { true })
          .and_then(continue),
        Comparser::Step.new
          .and_then(:chomp_if, ->(ch) { ch == "\"" })
          .and_then(done),
        Comparser::Step.new
          .and_then(:chomp_while, ->(ch) { ch != "\\" && ch != "\"" })
          .and_then(continue)
      ])
  end

  DoubleQuotedString = -> do
    Comparser::Step.new
      .and_then(:chomp_if, ->(ch) { ch == "\"" })
      .and_then(:sequence, DoubleQuotedStringHelper)
      .and_then { |state| state.good!(state.consume_chomped) }
  end
end
