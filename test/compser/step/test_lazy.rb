# frozen_string_literal: true

require "test_helper"

class Compser::Step::TestLazy < Minitest::Test
  include Compser  

  def test_lazy_without_recursion
    parser = take(:lazy, -> { take(:integer) })

    parser.parse("123").tap do |result|
      assert result.good?
      assert_equal 123, result.value
    end
  end

  def test_lazy_with_recursion
    comma_separated_integers = -> do
      take(:integer)
        .take(:one_of, [
          drop(:token, ',')
            .drop(:spaces)
            .take(:lazy, comma_separated_integers),
          succeed
        ])
    end

    parser = map(->(*integers) { integers }).and_then(comma_separated_integers.())

    parser.parse("1, 2, 3").tap do |result|
      assert result.good?
      assert_equal [1, 2, 3], result.value
    end

    parser.parse("1, 2,").tap do |result|
      assert result.bad?
      assert_equal "unexpected eof", result.message
    end
  end
end
