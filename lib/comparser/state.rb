# frozen_string_literal: true

class Comparser::State
  attr_accessor :offset, :line, :column, :chomped, :result_stack

  def initialize(source_code)
    @source_code = source_code
    @offset = 0
    @line = 0
    @column = 0
    @chomped = ::String.new("")
    @result_stack = [Comparser::Result::Good.new(self, nil)]
  end

  def result
    @result_stack.last
  end

  def eof?
    @offset >= @source_code.length
  end

  def peek(i = 0, n = 1)
    peek_offset = @offset + i

    return if peek_offset < 0
    return if peek_offset + n - 1 >= @source_code.length

    return @source_code[peek_offset, n]
  end

  def chomp
    return if @offset >= @source_code.length

    @chomped += @source_code[@offset]
    @offset += 1

    if peek(-1) == "\n"
      @line += 1
      @column = 0
    else
      @column += 1
    end

    self
  end

  def consume_chomped
    chomped = @chomped
    
    @chomped = ::String.new("")
    
    chomped
  end

  def good?
    @result_stack.last.good?
  end

  def bad?
    !good?
  end

  def pop_results(n)
    @result_stack.pop(n)
  end

  def good!(value)
    @result_stack.push(good(value)) and return self
  end

  def bad!(message)
    @result_stack.push(bad(message)) and return self
  end

  def good(value)
    return value if value.is_a?(Comparser::Result::Good)

    Comparser::Result::Good.new(self, value)
  end

  def bad(message)
    return message if message.is_a?(Comparser::Result::Bad)

    Comparser::Result::Bad.new(self, message)
  end
end
