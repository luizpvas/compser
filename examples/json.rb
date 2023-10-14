require_relative "../lib/comparser"

module MyJson
  extend Comparser
  extend self

  def parse(str)
    value.parse(str)
  end

  def value
    take(:one_of, [
      take(:double_quoted_string),
      number,
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
        .take(value)
        .drop(:spaces)
        .take(:one_of, [
          drop(:token, ",").drop(:spaces).and_then(continue),
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
    comma_separated_values = ->(continue, done) do
      take(value)
        .drop(:spaces)
        .take(:one_of, [
          succeed.drop(:token, ",").drop(:spaces).and_then(continue),
          done
        ])
    end

    map(->(*values) { values })
      .drop(:token, "[")
      .drop(:spaces)
      .take(:sequence, comma_separated_values)
      .drop(:token, "]")
  end

  def number
    take(:one_of, [
      map(->(x) { x * -1 }).drop(:token, "-").drop(:decimal),
      take(:decimal)
    ])
  end

  def boolean
    take(:one_of, [
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
