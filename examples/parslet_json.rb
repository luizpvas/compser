# frozen_string_literal: true
# https://github.com/kschiess/parslet/blob/master/example/json.rb

#
# MIT License - (c) 2011 John Mettraux
#

require 'parslet'

module Parslet::Json
  class Parser < Parslet::Parser

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:comma) { spaces? >> str(',') >> spaces? }
    rule(:digit) { match('[0-9]') }

    rule(:number) {
      (
        str('-').maybe >> (
          str('0') | (match('[1-9]') >> digit.repeat)
        ) >> (
          str('.') >> digit.repeat(1)
        ).maybe >> (
          match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
        ).maybe
      ).as(:number)
    }

    rule(:string) {
      str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:string) >> str('"')
    }

    rule(:array) {
      str('[') >> spaces? >>
      (value >> (comma >> value).repeat).maybe.as(:array) >>
      spaces? >> str(']')
    }

    rule(:object) {
      str('{') >> spaces? >>
      (entry >> (comma >> entry).repeat).maybe.as(:object) >>
      spaces? >> str('}')
    }

    rule(:value) {
      string | number |
      object | array |
      str('true').as(:true) | str('false').as(:false) |
      str('null').as(:null)
    }

    rule(:entry) {
      (
         string.as(:key) >> spaces? >>
         str(':') >> spaces? >>
         value.as(:val)
      ).as(:entry)
    }

    rule(:attribute) { (entry | value).as(:attribute) }

    rule(:top) { spaces? >> value >> spaces? }

    root(:top)
  end

  class Transformer < Parslet::Transform

    class Entry < Struct.new(:key, :val); end

    rule(:array => subtree(:ar)) {
      ar.is_a?(Array) ? ar : [ ar ]
    }
    rule(:object => subtree(:ob)) {
      (ob.is_a?(Array) ? ob : [ ob ]).inject({}) do |h, e|
        if e.is_a?(Hash) && e[:entry]
          h[e.dig(:entry, :key)] = e.dig(:entry, :val)
        else
          h[e.key] = e.val
        end

        h 
      end
    }

    rule(:entry => { :key => simple(:ke), :val => simple(:va) }) {
      Entry.new(ke, va)
    }

    rule(:string => simple(:st)) {
      st.to_s
    }
    rule(:number => simple(:nb)) {
      nb.match(/[eE\.]/) ? Float(nb) : Integer(nb)
    }

    rule(:null => simple(:nu)) { nil }
    rule(:true => simple(:tr)) { true }
    rule(:false => simple(:fa)) { false }
  end

  def self.parse(s)

    parser = Parser.new
    transformer = Transformer.new

    tree = parser.parse(s)
    out = transformer.apply(tree)

    out
  end
end
