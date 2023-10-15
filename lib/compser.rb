# frozen_string_literal: true

require_relative "compser/version"
require_relative "compser/result"
require_relative "compser/savepoint"
require_relative "compser/state"
require_relative "compser/step/backtrack"
require_relative "compser/step/chomp_if"
require_relative "compser/step/chomp_while"
require_relative "compser/step/decimal"
require_relative "compser/step/double_quoted_string"
require_relative "compser/step/drop"
require_relative "compser/step/integer"
require_relative "compser/step/keyword"
require_relative "compser/step/lazy"
require_relative "compser/step/one_of"
require_relative "compser/step/problem"
require_relative "compser/step/sequence"
require_relative "compser/step/spaces"
require_relative "compser/step/token"
require_relative "compser/step"

module Compser
  def succeed
    Step.new
  end

  def map(mapper)
    Step.new(mapper)
  end

  def take(...)
    Step.new.and_then(...)
  end

  def drop(...)
    Step.new.drop(...)
  end
end
