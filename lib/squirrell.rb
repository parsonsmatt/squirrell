require "squirrell/version"

module Squirrell
  class << self
    attr_accessor :classes
    attr_reader :executor

    def executor=(e)
      fail ExecutorError, "Executor must respond to `#call`" unless e.respond_to? :call
      @executor = e
    end
  end

  def self.configure
    yield self
  end

  def raw_sql
    nil
  end

  def process(results)
    results
  end

  class ExecutorError < ArgumentError; end;

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
      do_query(
        new(
          args
        )
      )
    end

    def klass.do_query(object)
      if object.respond_to? :finder
        object.finder
      else 
        sql = object.raw_sql || object.arel.to_sql
        puts Squirrell.executor
        object.process(Squirrell.executor.call(sql))
      end
    end
  end
end
