# Comparser

Comparser is a parser 

```ruby
module MyApp::Point2D
  include Comparser::Parser

  Value = Data.define(:x, :y)

  def parser
    map Value do
      succeed
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
  * `double_quoted_string`
  * `spaces`
* Syntax definition
  * `map`
  * `one_of`
  * `loop`
  * `sequence`
* Low level
  * `chomp_if`
  * `chomp_while`
  * `and_then`
  * `assert_peek`
* `debug`

## What's up with `.+`, `.-` and `.>>`?

`map`, `symbol`, `spaces` and `decimal` are parser steps that receive
a parser and return a parser. We combine them using one of the three operators:

* `.-` (`.drop` alias) - Ignore the value produced by the step
* `.+` (`.take` alias) - Push the value produced by the step to the result stack.
* `.*` (`.compose` alias) - Manual control over the state. Usually used with lower level constructs such as `chomp_if`, `chomp_while` and `and_then`.
