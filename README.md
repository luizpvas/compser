# Comparser

```ruby
module MyApp::Point2D
  include Comparser

  Value = ::Data.define(:x, :y)

  def parser
    map(Value)
      ._ symbol '('
      ._ spaces
      .+ float
      ._ spaces
      ._ symbol ','
      ._ spaces
      .+ float
      ._ spaces
      ._ symbol ')'
  end
end

result = MyApp::Point2D.parse('(1.5, 0.00009 )')

result.good? # => true
result.value # => MyApp::Point2D::Value[x: 1.5, y: 0.00009]
```