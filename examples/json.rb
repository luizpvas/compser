require_relative "../lib/comparser"

module MyJson
  extend Comparser
  extend self

  def parse(str)
    expression.call(Comparser::State.new(str)).result
  end

  def expression
    succeed.and_then(:one_of, [
      succeed.and_then(:decimal),
      succeed.and_then(:double_quoted_string),
      boolean,
      array,
      object
    ])
  end

  def object
    comma_separated_kv_pair = ->(continue, done) do
      map(->(key, value) { [key, value] })
        .take(:double_quoted_string)
        .drop(:spaces)
        .drop(:token, ":")
        .drop(:spaces)
        .take(expression)
        .drop(:spaces)
        .take(:one_of, [
          succeed.drop(:token, ",").drop(:spaces).and_then(continue),
          done
        ])
    end
    
    map(->(*pairs) { pairs.to_h })
      .drop(:token, "{")
      .drop(:spaces)
      .take(:sequence, comma_separated_kv_pair)
      .drop(:token, "}")
  end

  def array
    comma_separated_expression = ->(continue, done) do
      succeed
        .take(expression)
        .drop(:spaces)
        .take(:one_of, [
          succeed.drop(:token, ",").drop(:spaces).and_then(continue),
          done
        ])
    end

    map(->(*values) { values })
      .drop(:token, "[")
      .drop(:spaces)
      .take(:sequence, comma_separated_expression)
      .drop(:token, "]")
  end

  def boolean
    succeed.and_then(:one_of, [
      map(-> { true }).drop(:token, "true"),
      map(-> { false }).drop(:token, "false")
    ])
  end
end

json = <<~JSON
  {
    "key": "value",
    "key2": [true, false, "Hello world", [10, 20], { "key": "value" }]
  }
JSON

puts MyJson.parse(json).value.inspect
