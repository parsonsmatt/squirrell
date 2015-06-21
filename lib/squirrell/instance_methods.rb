module Squirrell
  # Instance methods for Squirrell objects.
  module InstanceMethods
    # Override this method to do raw_sql.
    def raw_sql
      sql = arel
      fail InvalidArelError unless sql.respond_to? :to_sql
      sql.to_sql
    end

    # Override this method to do arel.
    # Note: If you've overridden raw_sql, it won't work.
    def arel
      nil
    end

    # Override this method to skip SQL execution.
    def finder
      nil
    end

    # Override this method to process results after query execution.
    def process(results)
      results
    end

    def initialize(args)
      Squirrell.requires[self.class].each do |k|
        unless args.keys.include? k
          fail MissingParameterError, "Missing required parameter: #{k}"
        end
        instance_variable_set "@#{k}", args.delete(k)
      end

      Squirrell.permits[self.class].each do |k|
        instance_variable_set "@#{k}", args.delete(k) if args.keys.include? k
      end

      fail UnusedParameter, "Unspecified parameters: #{args}" if args.any?
    end
  end
end
