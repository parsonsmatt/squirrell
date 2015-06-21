Squirrell.configure do |sqrl|
  # executor is any object that responds to `call`. It will be called with
  # the generated SQL. An example for ActiveRecord is provided:
  sqrl.executor = -> (query) { ActiveRecord::Base.connection.execute(query) }
end
