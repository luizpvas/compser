module MyApp::Json
  include Comparser::Parser

  JString    = Data.define(:value)
  JNumber    = Data.define(:value)
  JBool      = Data.define(:value)
  JArray     = Data.define(:values)
  JObject    = Data.define(:pairs)

  def expression
    one_of [ string, number, boolean ]
  end

  def boolean
    one_of [
      map(1, JBool.new(true)) + keyword("true"),
      map(1, JBool.new(false)) + keyword("false")
    ]
  end

  def number
    map(1, JNumber) + decimal
  end

  def string
    map(1, JString) + double_quoted_string
  end
end
