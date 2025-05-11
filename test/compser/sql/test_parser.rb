# frozen_string_literal: true

require "test_helper"

class Compser::SQL::TestParser < Minitest::Test
  def test_select_basic
    assert_sql <<~SQL
      SELECT
        1
    SQL

    assert_sql <<~SQL
      SELECT
        1 AS val1,
        2 AS val2
    SQL
  end

  def assert_sql(sql)
    result = ::Compser::SQL::Parser.parse(sql).tap { assert _1.good? }

    formatted_sql = ::Compser::SQL::Formatter::Format.call(result.value)

    assert_equal sql.strip, formatted_sql, <<~TEXT
      Expected

      [#{formatted_sql}]

      to equal

      [#{sql}]
    TEXT
  end
end