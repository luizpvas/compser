# frozen_string_literal: true

module Comparser::Parser
  class State
    attr_reader :offset, :line, :column, :result_stack, :savepoint_offset

    def initialize(source_code)
      @source_code = source_code
      @offset = 0
      @line = 0
      @column = 0
      @chomped = ::String.new("")
      @result_stack = [Result::Good.new(self, nil)]
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
      return if peek_offset >= @source_code.length

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
    
    def peek_chomped
      @chomped
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
      return value if value.is_a?(Result::Good)

      Result::Good.new(self, value)
    end

    def bad(message)
      return message if message.is_a?(Result::Bad)

      Result::Bad.new(self, message)
    end

    def savepoint
      raise ArgumentError, "already have a savepoint" if @savepoint_result_stack

      @savepoint_result_stack  = @result_stack.dup
      @savepoint_offset        = @offset
      @savepoint_line          = @line
      @savepoint_column        = @column
      @savepoint_chomped       = @chomped
    end

    def has_changes_since_savepoint?
      @offset > @savepoint_offset
    end

    def rollback
      return if @savepoint_result_stack.nil?

      @result_stack  = @savepoint_result_stack
      @offset        = @savepoint_offset
      @line          = @savepoint_line
      @column        = @savepoint_column
      @chomped       = @savepoint_chomped

      @savepoint_result_stack  = nil
      @savepoint_offset        = nil
      @savepoint_line          = nil
      @savepoint_column        = nil
      @savepoint_chomped       = nil
    end

    def commit
      @savepoint_result_stack  = nil
      @savepoint_offset        = nil
      @savepoint_line          = nil
      @savepoint_column        = nil
      @savepoint_chomped       = nil
    end
  end
end
