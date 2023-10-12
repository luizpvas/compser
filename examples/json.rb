module JsonParser
  include Comparser::Parser

  def expression
    one_of [ double_quoted_string, decimal, boolean ]
  end

  def boolean
    one_of [
      map(1, true) + keyword("true"),
      map(1, false) + keyword("false")
    ]
  end
end
