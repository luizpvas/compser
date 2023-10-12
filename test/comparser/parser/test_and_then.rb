# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestAndThen < Minitest::Test
  include Comparser::Parser

  IsDigit = ->(ch) { ch.match?(/\d/) }

  ToInteger = ->(state) do
    state.good! Integer(state.consume_chomped)
  rescue ArgumentError
    state.bad!("expected integer")
  end

  def test_and_then_success_returning_good_result
    integer = chomp_while(is_good: IsDigit) >> and_then(to_value: ToInteger)

    result = parse("123", integer)

    assert result.good?
    assert_equal 123, result.value
  end

  def test_and_then_success_returning_bad_result
    integer = chomp_while(is_good: IsDigit) >> and_then(to_value: ToInteger)

    result = parse("abc", integer)

    assert result.bad?
    assert_equal "expected integer", result.message
  end

  def test_and_then_failure
    integer =
      chomp_if(error_message: "expected digit", is_good: IsDigit)
        .+ and_then(to_value: ->(_) { raise "and_then should not be called" })

    result = parse("abc", integer)

    assert result.bad?
    assert_equal "expected digit", result.message
  end
end
