require "squirrell/version"

module Squirrell
  attr_accessor :executor

  def self.configure
    yield self
  end

  def exec
    finder || executor.execute(raw_sql)
  end

  def raw_sql
    arel.to_sql
  end

  def result
    process exec
  end

  def process(results)
    results
  end
end
