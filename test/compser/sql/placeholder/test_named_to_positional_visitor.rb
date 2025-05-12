# frozen_string_literal: true

require "test_helper"

class Compser::SQL::Placeholder::TestNamedToPositionalVisitor < Minitest::Test
  def test_one_named_placeholder
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

  def test_two_named_placeholders
    positional_placeholders, sql =
      replace_named_placeholders_with_positional_placeholders <<~SQL
        SELECT * FROM users WHERE role = :role AND id = :id
      SQL

    assert_equal 2, positional_placeholders.size
    assert_equal 1, positional_placeholders["role"]
    assert_equal 2, positional_placeholders["id"]

    assert_equal <<~SQL.strip, sql
      SELECT
        *
      FROM
        users
      WHERE
        role = $1 AND id = $2
    SQL
  end

  def test_named_placeholder_repeated_twice
    positional_placeholders, sql =
      replace_named_placeholders_with_positional_placeholders <<~SQL
        SELECT * FROM users WHERE role = :role AND id = :role
      SQL

    assert_equal 1, positional_placeholders.size
    assert_equal 1, positional_placeholders["role"]

    assert_equal <<~SQL.strip, sql
      SELECT
        *
      FROM
        users
      WHERE
        role = $1 AND id = $1
    SQL
  end

  def test_no_named_placeholders
    positional_placeholders, sql =
      replace_named_placeholders_with_positional_placeholders <<~SQL
        SELECT * FROM users
      SQL

    assert_equal 0, positional_placeholders.size

    assert_equal <<~SQL.strip, sql
      SELECT
        *
      FROM
        users
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
