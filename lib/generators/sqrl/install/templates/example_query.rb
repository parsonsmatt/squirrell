class ExampleQuery
  include Squirrell

  # Requires indicates the parameters necessary for the query.
  # Called like: `ExampleQuery.find(id: 5, name: "alice", email: "cto@fancycorp.com")`
  # The values will be made available to queries as instance variables of the
  # same name.
  requires :id, :name, :email

  # process handles the result of the query before passing it to the caller.
  # It's defined by default like this.
  def process(result)
    result
  end

  # `#finder` execute the code in the method and pass directly to `#process`.
  # Great for ActiveRecord `find_by`, `where`, etc.
  def finder
    User.find_by(id: @id, name: @name, email: @email)
  end

  # `#arel` is where you might put Arel code. As long as the return value of
  # the method responds to `to_sql`, you're good. The code will be converted to
  # SQL, executed, and passed into process.
  def arel
    users = User.arel_table
    users.where(users[:name].eq(@name))
         .project(users[:email])
  end

  # `#raw_sql` is for raw sql code. It gets executed and passed to process.
  def raw_sql
    "SELECT * FROM users WHERE name = '#{@name}'"
  end
end
