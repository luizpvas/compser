require_relative "../lib/compser"

module MyJson
  extend Compser
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

  CommaSeparatedKeyValuePairs = ->(continue, done) do
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

  def object
    map(->(*pairs) { pairs.to_h })
      .drop(:token, "{")
      .drop(:spaces)
      .take(:sequence, CommaSeparatedKeyValuePairs)
      .drop(:token, "}")
  end

  CommaSeparatedValues = ->(continue, done) do
    take(value)
      .drop(:spaces)
      .take(:one_of, [
        succeed.drop(:token, ",").drop(:spaces).and_then(continue),
        done
      ])
  end

  def array
    map(->(*values) { values })
      .drop(:token, "[")
      .drop(:spaces)
      .take(:sequence, CommaSeparatedValues)
      .drop(:token, "]")
  end

  def number
    take(:one_of, [
      map(->(x) { x * -1 }).drop(:token, "-").take(:decimal),
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
