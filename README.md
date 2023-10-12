# Comparser

```ruby
module MyApp::Point2D
  include Comparser::Parser

  Value = Data.define(:x, :y)

  def point
    map(2, Value)
      .- symbol '('
      .- spaces
      .+ decimal
      .- spaces
      .- symbol ','
      .- spaces
      .+ decimal
      .- spaces
      .- symbol ')'
  end
end

result = MyApp::Point2D.parse('(1.5, 0.00009 )')

result.good? # => true
result.value # => MyApp::Point2D::Value[x: 1.5, y: 0.00009]
```