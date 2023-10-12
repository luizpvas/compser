# Comparser

Comparser is a parser 

```ruby
module MyApp::Point2D
  include Comparser::Parser

  Value = Data.define(:x, :y)

  def parse(source_code)
    super(source_code, point)
  end

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

## All functions

* High level
  * `integer`
  * `keyword`
  * `symbol`
  * `spaces`
* Syntax definition
  * `map`
  * `one_of`
  * `sequence`
* Low level
  * `chomp_if`
  * `chomp_while`
  * `and_then`
  * `assert_peek`
* `debug`

## What's up with `.+`, `.-` and `._`?

`map`, `symbol`, `spaces` and `decimal` are parser steps that receive
a parser and return a parser. We combine them using one of the three operators:

* `.-` (`.drop` alias) - Ignore the value produced by the step
* `.+` (`.take` alias) - Push the value produced by the step to the result stack.
* `._` (`.compose` alias) - Manual control over the state. Usually used with lower level constructs such as `chomp_if`, `chomp_while` and `and_then`.
