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

    assert_sql <<~SQL
      SELECT
        name,
        email_address
      FROM
        users
    SQL

    assert_sql <<~SQL
      SELECT
        application.name AS application_name,
        name,
        email_address
      FROM
        users
      INNER JOIN
        applications ON applications.id = users.application_id
      WHERE
        users.role = 1
    SQL

    assert_sql <<~SQL
      SELECT
        name
      FROM
        users
      WHERE
        users.role = 1 AND users.status = 2
    SQL
  end

  def assert_sql(sql)
    result = ::Compser::SQL::Parser.parse(sql)

    raise ::Compser::SQL::Parser.debug(sql).inspect if result.bad?

    formatted_sql = ::Compser::SQL::Formatter.format(result.value)

    assert_equal sql.strip, formatted_sql.strip, <<~TEXT
      Expected

      [#{formatted_sql}]

      to equal

      [#{sql}]
    TEXT
  end
end