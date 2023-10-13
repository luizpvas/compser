# frozen_string_literal: true

require_relative "comparser/version"
require_relative "comparser/result"
require_relative "comparser/savepoint"
require_relative "comparser/state"
require_relative "comparser/step"

module Comparser
  def succeed
    Step.new
  end
end
