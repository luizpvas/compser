# frozen_string_literal: true

require_relative "json"
require "json"
require "benchmark"
require "stringio"
require "parsby"
require "parsby/example/json_parser"

json = File.read("./json-payload.json")

n = 100

5000.times do; Compser::Json.parse(json); end

Benchmark.bm do |x|
  x.report("Compser::Json.parse") { n.times do; Compser::Json.parse(json); end }
  x.report("JSON.parse")   { n.times do; ::JSON.parse(json); end }
  x.report("Parsby")       { n.times do; Parsby::Example::JsonParser.parse(json); end }
end

puts RubyVM::YJIT.runtime_stats
