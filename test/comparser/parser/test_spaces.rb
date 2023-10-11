# frozen_string_literal: true

require "test_helper"

class Comparser::Parser::TestSpaces < Minitest::Test
  include Comparser::Parser
  
  def test_spaces
    source_code = "  \n   a"

    result = parse(source_code, spaces)
    
    assert result.good?
    assert_equal "  \n   ", result.state.peek_chomped
  end
end
