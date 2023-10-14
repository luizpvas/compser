# frozen_string_literal: true

require_relative "json"
require "json"
require "benchmark"

json = File.read("./json-payload.json")

n = 5000

n.times do; MyJson.parse(json); end

Benchmark.bm do |x|
  x.report("MyJson.parse") { n.times do; MyJson.parse(json); end }
  x.report("JSON.parse")   { n.times do; ::JSON.parse(json); end }
end

puts RubyVM::YJIT.runtime_stats
