# frozen_string_literal: true

class Comparser::Parser::State
  attr_reader :offset, :line, :column

  def initialize(source_code)
    @source_code = source_code
    @offset = 0
    @line = 0
    @column = 0
    @chomped = ::String.new("")
  end

  def peek(i = 0)
    peek_offset = @offset + i

    return if peek_offset < 0
    return if peek_offset >= @source_code.length

    @source_code[peek_offset]
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
  end
  
  def peek_chomped
    @chomped
  end

  def consume_chomped
    chomped = @chomped
    
    @chomped = ::String.new("")
    
    chomped
  end
end
