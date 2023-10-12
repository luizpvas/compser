# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::Step::TestCompose < Minitest::Test
  include Comparser::Parser

  def test_compose
    sum = Comparser::Parser::Step.new { _1 + _1 }
    mul = Comparser::Parser::Step.new { _1 * _1 }

    result = sum.compose(mul).call(2)

    assert_equal (2 + 2) * (2 + 2), result
  end

  def test_compose_with_operator_syntax
    sum = Comparser::Parser::Step.new { _1 + _1 }
    mul = Comparser::Parser::Step.new { _1 * _1 }

    result = sum >> mul

    assert_instance_of Comparser::Parser::Step, result
    assert_equal (2 + 2) * (2 + 2), result.call(2)
  end
end
