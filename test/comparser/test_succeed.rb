# frozen_string_literal: true

require "test_helper"

class Comparser::TestSucceed < Minitest::Test
  include Comparser

  def test_succeed
    parser = succeed()

    assert_instance_of Step, parser
  end
end
