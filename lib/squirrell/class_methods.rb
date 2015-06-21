module Squirrell
  # Class methods for Squirrell objects.
  module ClassMethods
    def requires(*args)
      Squirrell.requires[self] = args
    end

    def permits(*args)
      Squirrell.permits[self] = args
    end

    def find(args = {})
      do_query(new(args))
    end

    private

    def do_query(object)
      result = object.finder || Squirrell.executor.call(object.raw_sql)
      object.process(result)
    end
  end
end

