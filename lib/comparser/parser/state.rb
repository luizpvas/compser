# frozen_string_literal: true

module Comparser::Parser
  class State
    attr_reader :offset, :line, :column, :result

    def initialize(source_code)
      @source_code = source_code
      @offset = 0
      @line = 0
      @column = 0
      @chomped = ::String.new("")
      @result = Result::Good.new(self, nil)
    end

    def eof?
      @offset >= @source_code.length
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
      @result.good?
    end

    def good!(value)
      @result = good(value) and return self
    end

    def bad!(message)
      @result = bad(message) and return self
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
      raise ::ArgumentError, "already have a savepoint" if @savepoint_result

      @savepoint_result  = @result
      @savepoint_offset  = @offset
      @savepoint_line    = @line
      @savepoint_column  = @column
      @savepoint_chomped = @chomped
    end

    def rollback
      return if @savepoint_result.nil?

      @result  = @savepoint_result
      @offset  = @savepoint_offset
      @line    = @savepoint_line
      @column  = @savepoint_column
      @chomped = @savepoint_chomped

      @savepoint_result  = nil
      @savepoint_offset  = nil
      @savepoint_line    = nil
      @savepoint_column  = nil
      @savepoint_chomped = nil
    end

    def commit
      @savepoint_result  = nil
      @savepoint_offset  = nil
      @savepoint_line    = nil
      @savepoint_column  = nil
      @savepoint_chomped = nil
    end
  end
end
