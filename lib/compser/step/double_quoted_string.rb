# frozen_string_literal: true

class Compser::Step
  IsUninteresting = ->(ch) do
    ch != "\\" && ch != "\""
  end
  
  AssertNotEof = ->(state) do
    return state.bad!("unexpected eof") if state.eof?

    state
  end

  DoubleQuotedStringHelper = ->(continue, done) do
    Compser::Step.new
      .and_then(:one_of, [
        Compser::Step.new
          .and_then(:chomp_if, ->(ch) { ch == "\\" })
          .and_then(:chomp_if, ->(_) { true })
          .and_then(continue),
        Compser::Step.new
          .drop(:chomp_if, ->(ch) { ch == "\"" })
          .and_then(done),
        Compser::Step.new
          .and_then(:chomp_if, IsUninteresting)
          .and_then(:chomp_while, IsUninteresting)
          .and_then(AssertNotEof)
          .and_then(continue)
      ])
  end

  DoubleQuotedString = -> do
    Compser::Step.new
      .drop(:chomp_if, ->(ch) { ch == "\"" })
      .and_then(:sequence, DoubleQuotedStringHelper)
      .and_then { |state| state.good!(state.consume_chomped) }
  end
end
