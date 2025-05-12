# frozen_string_literal: true

require "test_helper"

class Compser::SQL::PlaceholderTest < Minitest::Test
  def test_placeholder_substitution
    ast = build_ast <<~SQL
      SELECT * FROM users WHERE role = :role
    SQL

    position_placeholders = ast.replace_named_placeholders_with_positional_placeholders!

    assert_equal 1, position_placeholders.size
    assert_equal 1, position_placeholders["role"]

    assert_equal <<~SQL.strip, ast.format
      SELECT
        *
      FROM
        users
      WHERE
        role = $1
    SQL
  end

  def build_ast(sql)
    result = ::Compser::SQL::Parser.parse(sql)

    assert result.good?

    ::Compser::SQL::AST.new(result.value)
  end
end
