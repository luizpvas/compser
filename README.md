# Comparser

* [`drop`](#drop)
* [`integer`](#integer)
* [`decimal`](#decimal)
* [`token`](#token)
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
parser = succeed
  .drop(:token, '[')
  .take(:integer)
  .drop(:token, ']')

parser.parse('[150]') # => Good<150>
parser.parse('[0]')   # => Good<0>

parser.parse('1234')  # => Bad<...>
parser.parse('[]')    # => Bad<...>
parser.parse('[900')  # => Bad<...>
```

#### `integer`

Parse integers with optional leading `-` for negatives.

```ruby
parser = succeed.take(:integer)

parser.parse('1')    # => Good<1>
parser.parse('1234') # => Good<1234>
parser.parse('-500') # => Good<-500>

parser.parse('1.34') # => Bad<...>
parser.parse('1e31') # => Bad<...>
parser.parse('123a') # => Bad<...>
parser.parse('0x1A') # => Bad<...>
```

#### `decimal`

Parse floating points as BigDecimal with optional leading `-` for negatives.

```ruby
parser = succeed.and_then(:decimal)

parser.parse('0.00009')  # => Good<0.00009>
parser.parse('-0.00009') # => Good<-0.00009>
parser.parse('bad')      # => Bad<...>
parser.parse('1e31')     # => Bad<...>
parser.parse('123a')     # => Bad<...>
```

#### `token`

Parses the exact string from source.

```ruby
parser = succeed.and_then(:token, 'module')


parser.parse('module')  # => Good<'module'>
parser.parse('modules') # => Good<'module'> or use `keyword` if you want a failure in this case.
parser.parse('modu')    # => Bad<...>
parser.parse('Module')  # => Bad<...>
```

#### `double_quoted_string`

Parses a string between double quotes ("). Line breaks and tabs inside the string is supported.

```ruby
parser = succeed.and_then(:double_quoted_string)

parser.call(Comparser::State.new('"Hello, world!"')).tap do |state|
  state.good?  # => true
  state.result # => Result::Good<value: 'Hello, world!'>
end
```

#### `map`

Calls the map function with the accumulated state's results. Accumuluate results are popped from the stack.
The return value from the map call is pushed to the stack. Important: The arity of the map function should
be equal to the amount of results produced in the pipeline.

```ruby
PlusOne = ->(x) { x + 1 }

parser = map(PlusOne).and_then(:integer)

parser.call(Comparser::State.new('99')).tap do |state|
  state.good?  # => true
  state.result # => Result::Good<value: 100>
end
```

#### `one_of`

Attempts to parse each branch in the order they were defined. If all branches fail, then the parser fails.
Important: The parser commits to the branch if it chomps from source or consumes or pushes a result. 

```ruby
parser = succeed.and_then(:one_of, [
  succeed.and_then(:integer),
  succeed.and_then(:double_quoted_string)
])

parser.call(Comparser::State.new('2023')).tap do |state|
  state.good?  # => true
  state.result # => Result::Good<value: 2023>
end

parser.call(Comparser::State.new('"Hello, world!"')).tap do |state|
  state.good?  # => true
  state.result # => Result::Good<value: 'Hello> world!']
end
```

#### `sequence`

Iterates over the same parser until it finishes. Results are accumulated

```ruby

CommaSeparatedInteger = ->(continue, done) do
  succeed
    .take(:integer)
    .drop(:spaces)
    .and_then(:one_of, [
      succeed.drop(:token, ',').drop(:spaces).and_then(continue),
      done
    ])
end

ToList = ->(*integers) { integers }

parser = map(ToList).take(:sequence, CommaSeparatedInteger)

parser.call(Comparser::State.new('12, 23, 34')).tap do |state|
  state.good? # => true
  state.result # => Result::Good<value: [12, 23, 34]>
end
```

#### `spaces`

Chompes zero or more blankspaces, line breaks and tabs. Always succeeds.

```ruby
parser = succeed.and_then(:spaces)

parser.call(Comparser::State.new('   \nfoo')).tap do |state|
  state.good?   # => true
  state.offset  # => 5
  state.chomped # => '   \n'
end
```

#### `chomp_if`

Chomps a single character from source if predicate returns true. Otherwise, a bad result is pushed to state.

```ruby
parser = succeed.and_then(:chomp_if, ->(ch) { ch == 'a' })

parser.call(Comparser::State.new('aaabb')).tap do |state|
  state.good?   # => true
  state.offset  # => 1
  state.chomped # => 'a'
end

parser.call(Comparser::State.new('bbbcc')).tap do |state|
  state.bad?    # => true
  state.offset  # => 0
  state.chomped # => ''
end
```

#### `chomp_while`

Chomps characters from source as long as predicate returns true. This function always leaves the state in a good
state, even if predicate returns false on the first run. It works as a zero-or-more loop.

```ruby
parser = succeed.and_then(:chomp_while, ->(ch) { ch == 'a' })

parser.call(Comparser::State.new('aaabb')).tap do |state|
  state.good?   # => true
  state.offset  # => 3
  state.chomped # => 'aaa'
end

parser.call(Comparser::State.new('bbbcc')).tap do |state|
  state.good?   # => true
  state.offset  # => 0
  state.chomped # => ''
end
``````