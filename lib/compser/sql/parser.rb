# frozen_string_literal: true

module Compser::SQL
  module Parser
    extend self
    include ::Compser

    def parse(text)
      select.parse(text)
    end

    def debug(text)
      ::Compser::State.new(text).tap { select.call(_1) }
    end

    def select
      map(->(result_columns, from, where) { [:select, result_columns, from, where] })
        .drop(:keywordi, "select")
        .drop(:spaces)
        .take(result_columns)
        .drop(:spaces)
        .take(:one_of, [ from, -> { _1.good!(nil) } ])
        .drop(:spaces)
        .take(:one_of, [ where, -> { _1.good!(nil) } ])
    end

    def result_columns
      map(->(*values) { values })
        .take(:sequence, ->(continue, done) do
          result_column
            .drop(:spaces)
            .take(:one_of, [
              drop(:token, ",").drop(:spaces).and_then(continue),
              done
            ])
        end)
    end

    def result_column
      take(:one_of, [
        result_column_star,
        result_column_expr
      ])
    end

    def result_column_star
      map(->() { :star })
        .drop(:token, "*")
    end

    def result_column_expr
      map(->(result_column, as) { as.nil? ? result_column : [:alias, result_column, as] })
        .take(expr)
        .drop(:spaces)
        .take(:one_of, [
          drop(:keywordi, "as").drop(:spaces).take(name),
          ->(state) { state.good!(nil) }
        ])
    end

    def from
      map(->(name, join) { [:from, name, join] })
        .drop(:keywordi, "from")
        .drop(:spaces)
        .take(name)
        .drop(:spaces)
        .take(:one_of, [
          inner_join,
          -> { _1.good!(nil) }
        ])
    end

    def inner_join
      map(->(related, left, right) { [:inner_join, related, left, "=", right] })
        .drop(:keywordi, "inner")
        .drop(:spaces)
        .drop(:keywordi, "join")
        .drop(:spaces)
        .take(name)
        .drop(:spaces)
        .drop(:keywordi, "on")
        .drop(:spaces)
        .take(name)
        .drop(:spaces)
        .drop(:token, "=")
        .drop(:spaces)
        .take(name)
    end

    def expr
      map(->(expr, f) { f.call(expr) })
        .take(expr_leaf)
        .drop(:spaces)
        .take(:one_of, [
          expr_binary,
          -> { _1.good!(->(x) { x }) }
        ])
    end

    def expr_leaf
      take(:one_of, [
        integer,
        named_variable,
        name
      ])
    end

    def expr_binary
      map(->(operator, expr_right) do
        lambda do |expr_left|
          [:expr_binary, expr_left, operator, expr_right]
        end
      end)
        .take(operator)
        .drop(:spaces)
        .take(:lazy, -> { expr })
    end

    def where
      map(->(expr) { [:where, expr] })
        .drop(:keywordi, "where")
        .drop(:spaces)
        .take(expr)
    end

    def integer
      map(->(value) { [:integer, value] })
        .take(:integer)
    end

    def operator
      take(:one_of, [
        take(:token, "="),
        take(:token, "!="),
        take(:token, "<>"),
        take(:token, ">"),
        take(:token, ">="),
        take(:token, "<"),
        take(:token, "<="),
        take(:token, "AND"),
        take(:token, "OR"),
        take(:token, "IN")
      ])
    end

    IsChar = ->(c) { c.match?(/[a-zA-Z_]/) }
    IsAlpha = ->(c) { c.match?(/[a-zA-Z0-9_\.]/) }

    def name
      map(->(name) { [:name, name] })
        .and_then(:chomp_if, IsChar)
        .and_then(:chomp_while, IsAlpha)
        .and_then { |state| state.good!(state.consume_chomped) }
    end

    def named_variable
      map(->(name) { [:named_variable, name] })
        .drop(:token, ":")
        .and_then(:chomp_if, IsChar)
        .and_then(:chomp_while, IsAlpha)
        .and_then { |state| state.good!(state.consume_chomped) }
    end
  end
end
