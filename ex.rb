# Example usage for Squirrell:

# Configuration:

Squirrell.configure do |config|
  config.executor = ActiveRecord::Base
end

# Basic AR finders:

class UserWithPosts
  include Squirrell

  required :id

  def finder
    User.includes(:posts).find(@id)
  end
end

UserWithPosts.find(id: 5)

# Raw SQL queries:

class SomeSqlQuery
  include Squirrell

  required :sql_param

  def raw_sql
    <<ENDSQL
SELECT * FROM asdf WHERE asdf.id <= #{@sql_param}
ENDSQL
  end
end

SomeSqlQuery.find(sql_param: 10)

# Arel:

class ArelQuery
  include Squirrell

  required :limit

  def arel
    some = SomeModel.arel_table
    other = OtherModel.arel_table
    some.join(other[:id].eq(some[:other_id]))
      .where(some[:prop] = @limit)
      .project(:id, :name)
  end
end

ArelQuery.find(limit: 20)
