require 'squirrell/version'
require 'squirrell/class_methods'
require 'squirrell/instance_methods'

# Including this module gives a few convenience methods for query objects.
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

  # Errors raised when the executor doesn't respond to call.
  class ExecutorError < ArgumentError; end

  # Error raised when result of `arel` doesn't respond to `to_sql`
  class InvalidArelError < ArgumentError; end

  # Error raised when a required parameter is not passed.
  class MissingParameterError < ArgumentError; end

  # Error raised when a parameter passed into `.find` is not included in either
  # requires or permits.
  class UnusedParameter < ArgumentError; end

  def self.included(klass)
    Squirrell.requires ||= {}
    Squirrell.requires[klass] = []
    Squirrell.permits ||= {}
    Squirrell.permits[klass] = []

    klass.extend ClassMethods
    klass.include InstanceMethods
  end
end
