# frozen_string_literal: true

require_relative "comparser/version"
require_relative "comparser/result"
require_relative "comparser/savepoint"
require_relative "comparser/state"
require_relative "comparser/step/chomp_if"
require_relative "comparser/step/chomp_while"
require_relative "comparser/step/integer"
require_relative "comparser/step"

module Comparser
  def succeed
    Step.new
  end

  def map(mapper)
    Step.new(mapper)
  end
end
