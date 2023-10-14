# Comparser

* [`drop`](#drop)
* [`integer`](#integer)
* [`decimal`](#decimal)
* [`token`](#token)
* [`keyword`](#keyword)
* [`double_quoted_string`](#double_quoted_string)
* [`map`](#map)
* [`one_of`](#one_of)
* [`sequence`](#sequence)
* [`spaces`](#spaces)
* [`chomp_if`](#chomp_if)
* [`chomp_while`](#chomp_while)

#### `drop`

Discard any result or chomped string produced by the parser.

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


# negative integers with '-' prefix
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

Parses the keyword from source. The next character after the keyword must be a space, symbol or number.

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
parser.parse('"Hello, world!"') # => Good<2023>
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

#### `spaces`

Chompes zero or more blankspaces, line breaks and tabs. Always succeeds.

```ruby
take(:spaces).parse('   \nfoo').state # => State<good?: true, offset: 5, chomped: '   \n'>
```

#### `chomp_if`

Chomps a single character from source if predicate returns true. Otherwise, a bad result is pushed to state.

```ruby
parser = take(:chomp_if, ->(ch) { ch == 'a' })

parser.parse('aaabb').state # => State<good?: true, offset: 1, chomped: 'a'>
parser.parse('cccdd').state # => State<good?: false, offset: 0, chomped: ''>
```

#### `chomp_while`

Chomps characters from source as long as predicate returns true. This parser always succeeds even if predicate
returns false for the first character. It is a zero-or-more loop.

```ruby
parser = take(:chomp_while, ->(ch) { ch == 'a' })

parser.parse('aaabb').state # => State<good?: true, offset: 3, chomped: 'aaa'>
parser.parse('cccdd').state # => State<good?: true, offset: 0, chomped: ''>
``````