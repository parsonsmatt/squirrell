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
      result = nil
      if object.finder
        result = object.finder
      else
        sql = object.raw_sql
        result = Squirrell.executor.call(sql)
      end
      object.process(result)
    end
  end
end
