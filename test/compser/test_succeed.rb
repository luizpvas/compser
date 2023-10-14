# frozen_string_literal: true

require "test_helper"

class Compser::TestSucceed < Minitest::Test
  include Compser

  def test_succeed
    parser = succeed()

    assert_instance_of Step, parser
  end
end
