# frozen_string_literal: true

require "test_helper"

class Compser::SQL::Placeholder::TestNamedToPositionalVisitor < Minitest::Test
  def test_named_to_positional_visitor
    positional_placeholders, sql =
      replace_named_placeholders_with_positional_placeholders <<~SQL
        SELECT * FROM users WHERE role = :role
      SQL

    assert_equal 1, positional_placeholders.size
    assert_equal 1, positional_placeholders["role"]

    assert_equal <<~SQL.strip, sql
      SELECT
        *
      FROM
        users
      WHERE
        role = $1
    SQL
  end

  def replace_named_placeholders_with_positional_placeholders(sql)
    result = ::Compser::SQL::Parser.parse(sql)

    assert result.good?

    visitor = ::Compser::SQL::Placeholder::NamedToPositionalVisitor.new
    visitor.visit(result.value)

    output = ::Compser::SQL::Formatter.format(result.value)

    [visitor.positional_placeholders, output]
  end
end
