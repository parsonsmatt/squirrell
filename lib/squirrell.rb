require 'squirrell/version'

module Squirrell
  class << self
    attr_accessor :classes
    attr_reader :executor

    def executor=(e)
      unless e.respond_to? :call
        fail ExecutorError, 'Executor must respond to `#call`'
      end
      @executor = e
    end
  end

  def self.configure
    yield self
  end

  def raw_sql
    sql = arel
    fail InvalidArelError unless sql.respond_to? :to_sql
    sql.to_sql
  end

  def process(results)
    results
  end

  class ExecutorError < ArgumentError; end
  class InvalidArelError < ArgumentError; end

  def self.included(klass)
    def klass.required(*args)
      Squirrell.classes ||= {}
      Squirrell.classes[self] = args
    end

    def initialize(args)
      args.each do |k, v|
        if Squirrell.classes[self.class].include? k
          instance_variable_set "@#{k}", v
        else
          fail ArgumentError, "required params incorrect: #{args}"
        end
      end
    end

    def klass.find(args = {})
      do_query(new(args))
    end

    def klass.do_query(object)
      result = nil
      if object.respond_to? :finder
        result = object.finder
      else
        sql = object.raw_sql
        result = Squirrell.executor.call(sql)
      end
      object.process(result)
    end
  end
end
