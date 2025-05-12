# frozen_string_literal: true

require "test_helper"

class Compser::SQL::Placeholder::TestNamedRemovalVisitor < Minitest::Test
  #def test_one_named_placeholder
  #  sql = remove_named_placeholders <<~SQL, ["role"]
  #    SELECT * FROM users WHERE role = :role
  #  SQL

  #  assert_equal <<~SQL.strip, sql
  #    SELECT
  #      *
  #    FROM
  #      users
  #  SQL
  #end

  def test_two_named_placeholders
    sql = remove_named_placeholders <<~SQL, ["role"]
      SELECT * FROM users WHERE role = :role AND status = :status
    SQL

    assert_equal <<~SQL.strip, sql
      SELECT
        *
      FROM
        users
      WHERE
        status = :status
    SQL
  end

  def remove_named_placeholders(sql, named_placeholders_to_remove)
    result = ::Compser::SQL::Parser.parse(sql)

    assert result.good?

    visitor = ::Compser::SQL::Placeholder::NamedRemovalVisitor.new(named_placeholders_to_remove)
    visitor.visit(result.value)

    ::Compser::SQL::Formatter.format(result.value)
  end
end
