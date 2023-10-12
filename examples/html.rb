module MyHtml
include Comparser::Parser

  Attribute = Data.define(:name, :value)

  def attribute
    map Attribute do
      attribute_name
        .- spaces
        .- symbol("=")
        .- spaces
        .+ one_of [ double_quoted_string, single_quoted_string, quoteless_attribute_value ]
    end
  end

  def attribute_name
    raise "todo"
  end

  def quoteless_attribute_value
    raise "todo"
  end
end
