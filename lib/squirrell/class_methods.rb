module Squirrell
  # Class methods for Squirrell objects.
  module ClassMethods
    def requires(*args)
      Squirrell.requires[self] = args
      define_readers args
    end

    def permits(*args)
      Squirrell.permits[self] = args
      define_readers args
    end

    def find(args = {})
      do_query(new(args))
    end

    private

    def do_query(object)
      result = object.finder || Squirrell.executor.call(object.raw_sql)
      object.process(result)
    end

    def define_readers(args)
      args.each do |arg|
        attr_reader arg
      end
    end
  end
end

