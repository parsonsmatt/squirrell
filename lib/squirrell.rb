require 'squirrell/version'

module Squirrell
  class << self
    attr_accessor :requires
    attr_accessor :permits
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
    Squirrell.requires ||= {}
    Squirrell.requires[klass] = []
    Squirrell.permits ||= {}
    Squirrell.permits[klass] = []

    def klass.requires(*args)
      Squirrell.requires[self] = args
    end

    def klass.permits(*args)
      Squirrell.permits[self] = args
    end

    def initialize(args)
      Squirrell.requires[self.class].each do |k|
        unless args.keys.include? k
          fail ArgumentError, "Missing required parameter: #{k}"
        end
        instance_variable_set "@#{k}", args.delete(k)
      end

      Squirrell.permits[self.class].each do |k|
        if args.keys.include? k
          instance_variable_set "@#{k}", args.delete(k)
        end
      end

      raise ArgumentError if args.any?
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
