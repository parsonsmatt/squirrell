# Squirrell

[![Gem Version](https://badge.fury.io/rb/squirrell.svg)](http://badge.fury.io/rb/squirrell)

Squirrell is a kinda magical library intended to make it easier to simplify your relationship with ActiveRecord.
ActiveRecord provides an immense amount of flexibility and power, and it's really easy to let this functionality become more-and-more intense.
Controllers doing arbitrary `where`s, other models doing a `find_by`, maybe even a hidden finder in the views somewhere.
This level of decoupling makes things difficult to test and obscures the lines in your application.

Squirrell makes it easy to create finders and query objects that respond very well to testing and are easy to mock.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'squirrell'
```

### Rails

Run the install generator to copy the initializer, add `app/queries` to Rails autoload, and provide an example query:

    $ rails generate sqrl:install

## Usage

### Configuring Squirrell

If you want to use any raw SQL or Arel querying, you'll need to provide Squirrell with an executor.
An executor responds to `:call`, accepts a single argument, and executes that argument as a SQL query.
It doesn't really have to execute a SQL query, though.
It just probably should.

To configure Squirrell, you can do a block in an initializer somewhere:

```ruby
Squirrell.configure do |sqrl|
  sqrl.executor = -> (sql) { ActiveRecord::Base.connection.execute(sql) }
end
```

### Using a Squirrell query class

Squirrell query classes have a very limited external interface.
They respond to `.find` and return the result of the query.
As a result, they're very easy to mock: `allow(ComplexQuery).to receive(:find).and_return(your_stubs)`

(hah hah, silly squirrell)

Examples:

```ruby
UserFinder.find(id: 6)
WizardByElementAndPet.find(element: :ice, pet: :penguin)
HeroByName.find(name: "Finn")
```

### Defining a Squirrell

There are currently three queries supported by Squirrell: `#finder`, `#arel`, and `#raw_sql`.

Finders are the simplest.
They just return the result of the `#finder` method.

```ruby
class UserFinder
  include Squirrell

  requires :id

  def finder
    User.find(id)
  end

  def process(result)
    result.map { |user| "Happy birthday, #{user.name}!" }
  end
end
```

The `requires :id` line indicates what parameters must be passed to `find`.
An error will be raised if a required parameter is missing or if an extra parameter is passed.
The symbols in the hash are made into instance variables of the same name.
`attr_readers` are provided for them, so you can refer to them without `@`.

After the finding method gets called, `#process` gets called with the result of the query.
In the previous example, `result` would be an array, and it would convert the found users into a string wishing them a happy birthday.
The return value of `process` is ultimately what the return value of `UserFinder.find` will be.

Arel finders are meant to be used in conjunction with the Arel gem.
In truth, the only requirement is that the return value of the `#arel` method respond to `:to_sql`.

```ruby
class WizardByElementAndPet
  include Squirrell

  requires :element, :pet

  def arel
    wizards = Wizard.arel_table
    wizards.where(wizards[:pet].eq(pet))
           .where(wizards[:element].eq(element))
           .project(wizards[:id])
  end
end
```

Finally, Squirrell can do raw SQL.
Define `#raw_sql` on the Squirrell class and it'll use the executor.
The string returned by `raw_sql` is passed directly to the executor.
Currently, it doesn't do anything clever to escape it.

```ruby
class HeroByName
  include Squirrell

  requires :name

  def raw_sql
    "SELECT heroes.id FROM heroes WHERE heroes.name = '#{name}'"
  end
end
```

Sometimes, you just want to return a bunch of models, and the finder has you totally covered.
Other times, the array-of-arrays or array-of-column-hashes are all you need.
When that isn't the case, Squirrell provides a `#process` hook that receives the result of the query and can do whatever it wants with it.

```ruby
class HeroByName
  # ...
  def process(result)
    puts result
    # => #<PG::Result:0x981723098 status=PGRES_TUPLES_OK etc....>
    puts result.values
    # => [["1"],["42"]]
    Hero.find(result.values.flatten)
  end
end

HeroByName.find(name: "Finn")
# => [#<Hero:0x0987123 name="Finn" weapon="Grass Sword", etc...]
```

Squirrell allows you to define optional permitted parameters:

```ruby
def PermissionExample
  include Squirrell

  requires :user_id
  permits :post_id

  def raw_sql
    <<SQL
SELECT *
FROM users
  INNER JOIN posts ON users.id = posts.user_id
WHERE users.id = #{user_id} #{has_post?}
SQL
  end

  def has_post?
    post_id ? "AND posts.id = #{post_id}" : ""
  end
end
```

Generally, this makes for more complex queries. If you're finding that you're customizing with a bunch of `permits`, you may want to make a new query object.

### Rails Generator

Squirrell has a generator for queries.

    $ rails generate sqrl:query QueryName id name --type=raw_sql

* `QueryName` is the name of the query object.
* `--type=` can either be `raw_sql`, `finder`, or `arel`. The default is `finder`
* The remaining elements are the required parameters for the query. The default is `id`.

## Testing Squirrells

Mocking Squirrels is really easy. `expect(QueryObject).to receive(:find).and_return(results)` will capture the desired behavior in calling classes.

Testing Squirrells has two components: testing that the interaction with the database works as expected, and testing that the post-processing method works as expected.

For basic ActiveRecord finders, it's not really necessary to test `.find`.
ActiveRecord is well-tested and unlikely to be cause problems.
For Arel and raw SQL queries that have a bit more complexity, you'll likely want to actually touch the database in these tests.

```ruby
describe HeroByName do
  before :all do
    let(:finn) { create(:hero, name: "Finn") }
    let(:jake) { create(:hero, name: "Jake") }
  end

  it 'finds by name' do
    result = HeroByName.find(name: "Finn")
    expect(result).to include(finn)
    expect(result).to_not include(jake)
  end
end
```

You can gain access to the underlying Squirrell with `.new`, which lets you test the `process` method and any other methods you choose to define on the class.

```ruby
describe MathQuery do
  class MathQuery
    include Squirrell

    requires :math

    def process(result)
      result * 5
    end
  end

  let(:subject) { MathQuery.new }

  it 'multiples result by 5' do
    expect(subject.process(5)).to eq(10)
  end
end
```

Generally, it'll be easiest to use and test the code if `process` is a pure function of it's input.
If you need to refer to those values, you can pass the parameters in to `new`: `MathQuery.new(math: "so cool")`.

## Wishlist

1. Test helpers and test generators.
2. A test hook that runs queries and caches them, similar to VCR.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/squirrell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
