# frozen_string_literal: true

module Comparser::Parser
  def chomp_if(&is_good)
    Step.new do |parser|
    end
  end

  def chomp_while(&is_good)
    Step.new do |parser|
    end
  end
end
