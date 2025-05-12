# frozen_string_literal: true

require "test_helper"

class Compser::SQL::Placeholder::TestNamedDetectionVisitor < Minitest::Test
  def test_one_named_placeholder
    named_placeholders = detect_named_placeholders <<~SQL
      SELECT * FROM users WHERE role = :role
    SQL

    assert_equal ["role"], named_placeholders
  end

  def test_two_named_placeholders
    named_placeholders = detect_named_placeholders <<~SQL
      SELECT * FROM users WHERE role = :role AND id = :id
    SQL

    assert_equal ["role", "id"], named_placeholders
  end

  def test_named_placeholder_repeated_twice
    named_placeholders = detect_named_placeholders <<~SQL
      SELECT * FROM users WHERE role = :role AND id = :role
    SQL

    assert_equal ["role"], named_placeholders
  end

  def test_no_named_placeholders
    named_placeholders = detect_named_placeholders <<~SQL
      SELECT * FROM users
    SQL

    assert_equal [], named_placeholders
  end

  def detect_named_placeholders(sql)
    result = ::Compser::SQL::Parser.parse(sql)

    assert result.good?

    visitor = ::Compser::SQL::Placeholder::NamedDetectionVisitor.new
    visitor.visit(result.value)
    visitor.named_placeholders
  end
end
