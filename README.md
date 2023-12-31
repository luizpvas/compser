# Compser

Compser is a parser builder library for Ruby inspired by [elm-parser](https://package.elm-lang.org/packages/elm/parser/latest/).
Take a look at the [JSON parser](https://github.com/luizpvas/Compser/blob/main/examples/json.rb) and [Calculator](https://github.com/luizpvas/compser/blob/main/examples/calculator.rb) to get a glimpse of the syntax
and building blocks you can use to build complex parsers.

* [Installation](#installation)
* [Benchmark](#benchmark)
* [Building blocks](#building-blocks)
  * [`drop`](#drop)
  * [`integer`](#integer)
  * [`decimal`](#decimal)
  * [`token`](#token)
  * [`keyword`](#keyword)
  * [`double_quoted_string`](#double_quoted_string)
  * [`map`](#map)
  * [`one_of`](#one_of)
  * [`sequence`](#sequence)
  * [`lazy`](#lazy)
  * [`spaces`](#spaces)
  * [`chomp_if`](#chomp_if)
  * [`chomp_while`](#chomp_while)

## Installation

Add the following line to your Gemfile:

```ruby
gem 'compser', '~> 0.2'
```

More details at [https://rubygems.org/gems/compser](https://rubygems.org/gems/compser).

## Benchmark

The following result is a benchark of a [JSON parser](https://github.com/luizpvas/Compser/blob/main/examples/json.rb) implemented with Compser compared against [Parsby](https://github.com/jolmg/parsby), [Parslet](https://github.com/kschiess/parslet) and `JSON.parse`.

[The benchmark](https://github.com/luizpvas/compser/blob/main/examples/json_benchmark.rb) parses a 1,5kb payload 100 times.

Implementation | Time | Compared to `JSON.parse`
:---:|:---:|:---:
`JSON.parse` | 0.00067s | -
[`Compser::Json`](https://github.com/luizpvas/compser/blob/main/examples/json.rb) with YJIT | 0.216s | 322x slower
[`Compser::Json`](https://github.com/luizpvas/compser/blob/main/examples/json.rb) | 0.268s | 400x slower
[`Parslet::MyJson`](https://github.com/kschiess/parslet/blob/master/example/json.rb) with YJIT | 0.43s | 641x slower
[`Parslet::MyJson`](https://github.com/kschiess/parslet/blob/master/example/json.rb) | 0.57s | 850x slower
[`Parsby::Example::JsonParser`](https://github.com/jolmg/parsby/blob/master/lib/parsby/example/json_parser.rb) with YJIT | 24.19s | 36100x slower
[`Parsby::Example::JsonParser`](https://github.com/jolmg/parsby/blob/master/lib/parsby/example/json_parser.rb) | 27.22s | 40626x slower

Compser is far behind `JSON.parse` with the native C implementation, but results seem pretty good compared to other Ruby implementations.

## Building blocks

#### `drop`

Discard results produced by the parser.

```ruby
parser = drop(:token, '[').take(:integer).drop(:token, ']')

parser.parse('[150]') # => Good<150>
parser.parse('[0]')   # => Good<0>

parser.parse('1234')  # => Bad<...>
parser.parse('[]')    # => Bad<...>
parser.parse('[900')  # => Bad<...>
```

#### `integer`

Parse integers.

```ruby
parser = take(:integer)

parser.parse('1')    # => Good<1>
parser.parse('1234') # => Good<1234>

parser.parse('-500') # => Bad<...>
parser.parse('1.34') # => Bad<...>
parser.parse('1e31') # => Bad<...>
parser.parse('123a') # => Bad<...>
parser.parse('0x1A') # => Bad<...>


# support negative integers with '-' prefix
def my_integer
  take(:one_of, [
    map(->(x) { x * -1 }).drop(:token, '-').take(:integer),
    take(:integer)
  ])
end
```

#### `decimal`

Parse floating points as BigDecimal.

```ruby
parser = take(:decimal)

parser.parse('0.00009')  # => Good<0.00009>

parser.parse('-0.00009') # => Bad<...>
parser.parse('bad')      # => Bad<...>
parser.parse('1e31')     # => Bad<...>
parser.parse('123a')     # => Bad<...>
```

#### `token`

Parses the token from source.

```ruby
parser = take(:token, 'module')


parser.parse('module')  # => Good<'module'>
parser.parse('modules') # => Good<'module'> or use `keyword` if you want a failure in this case.
parser.parse('modu')    # => Bad<...>
parser.parse('Module')  # => Bad<...>
```

#### `keyword`

Parses the keyword from source. Similar to `token`, but the next character after the keyword must be a space, symbol or number.

```ruby
parser = take(:keyword, 'let')

parser.parse('let')  # => Good<'let'>

parser.parse('letter') # => Bad<...>
parser.parse('Let')    # => Bad<...>
parser.parse('le')     # => Bad<...>
```

#### `double_quoted_string`

Parses a string between double quotes. Line breaks and tabs are supported.

```ruby
parser = take(:double_quoted_string)

parser.parse('"Hello, world!"')       # => Good<'Hello, world!'>
parser.parse('"line1\nline2"')        # => Good<'line1\\nline2'>
parser.parse('"Hello, \\"world\\"!"') # => Good<'Hello, "world"!'>

parser.parse('foo')       # => Bad<...>
parser.parse('foo "bar"') # => Bad<...>
parser.parse('"foo')      # => Bad<...>
```

#### `map`

Calls the map function with the taken values in the current pipeline if it succeeds. The output from map becomes the output of the parser,
that is, any parser with a map can be chained into other parsers.

Important: The arity of the map function should be equal to the amount of taken values in the pipeline.

```ruby
Sum = ->(a, b) { a + b }

parser = map(Sum).take(:integer).drop(:token, '+').take(:integer)

parser.parse('1+1') # => Good<2>
parser.parse('1+')  # => Bad<...>
```

#### `one_of`

Attempts to parse each branch in the order they appear in the list. If all branches fail then the parser fails.
Important: `one_of` will fail on the current branch it had a partial success before failing. The branch has to fail
early without chomping any character from source .

```ruby
parser = take(:one_of, [ take(:integer), take(:double_quoted_string) ])

parser.parse('2023')            # => Good<2023>
parser.parse('"Hello, world!"') # => Good<'Hello, world!'>
parser.parse('true')            # => Bad<...>
```

#### `sequence`

Iterates over the parser until `done` is called. We don't know in advance how many values are gonna be taken,
so the `map` call should use single splat operator to receive a list with all values taken in the loop.

```ruby

ToList = ->(*integers) { integers }

CommaSeparatedInteger = ->(continue, done) do
  take(:integer)
    .drop(:spaces)
    .take(:one_of, [
      drop(:token, ',').drop(:spaces).and_then(continue),
      done
    ])
end

parser = map(ToList).take(:sequence, CommaSeparatedInteger)

parser.parse('12, 23, 34') # => Good<[12, 23, 34]>
parser.parse('123')        # => Good<[123]>

parser.parse('12,')        # => Bad<...>
parser.parse(',12')        # => Bad<...>
```

#### `lazy`

Wraps a parser in a lazy-evaluated proc. Use `lazy` to build recursive parsers.

```ruby
ToList = ->(*integers) { integers }

CommaSeparatedInteger = -> do
  take(:integer)
    .drop(:spaces)
    .take(:one_of, [
      drop(:token, ',').drop(:spaces).take(:lazy, CommaSeparatedInteger),
      succeed
    ])
end

parser = map(ToList).take(CommaSeparatedInteger.call())

parser.parse('12, 23, 34') # => Good<[12, 23, 34]>
parser.parse('123')        # => Good<[123]>

parser.parse('12,')        # => Bad<...>
parser.parse(',12')        # => Bad<...>
```

#### `spaces`

Chompes zero or more blankspaces, line breaks and tabs. Always succeeds.

```ruby
Compser::State.new('   \nfoo').tap { take(:spaces).call(_1) } # => State<good?: true, offset: 5, chomped: '   \n'>
```

#### `chomp_if`

Chomps a single character from source if predicate returns true. Otherwise, a bad result is pushed to state.

```ruby
parser = take(:chomp_if, ->(ch) { ch == 'a' })

Compser::State.new('aaabb').tap { parser.call(_1) } # => State<good?: true, offset: 1, chomped: 'a'>
Compser::State.new('cccdd').tap { parser.call(_1) } # => State<good?: false, offset: 0, chomped: ''>
```

#### `chomp_while`

Chomps characters from source as long as predicate returns true. This parser always succeeds even if predicate
returns false for the first character. It is a zero-or-more loop.

```ruby
parser = take(:chomp_while, ->(ch) { ch == 'a' })

Compser::State.new('aaabb').tap { parser.call(_1) } # => State<good?: true, offset: 3, chomped: 'aaa'>
Compser::State.new('cccdd').tap { parser.call(_1) } # => State<good?: true, offset: 0, chomped: ''>
```
