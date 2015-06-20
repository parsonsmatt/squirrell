# Squirrell

Squirrell is a completely non-magical library intended to make it easier to simplify your relationship with ActiveRecord.
ActiveRecord provides an immense amount of flexibility and power, and it's really easy to let this functionality become more-and-more intense.
Controllers doing arbitrary `where`s, other models doing a `find_by`, maybe even a hidden finder in the views somewhere.
This level of decoupling makes things difficult to test and obscures the lines in your application.

Squirrell makes it easy to create finders and query objects that respond very well to testing and are easy to mock.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'squirrell'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install squirrell

## Usage

### Configuring Squirrell

If you want to use any raw SQL or Arel querying, you'll need to provide Squirrell with an executor.
An executor responds to `:call`, accepts a single argument, and executes that argument as a SQL query.
It doesn't really have to execute a SQL query, though.
It just probably should.

To configure Squirrell, you can do a block:

```ruby
Squirrell.configure do |sqrrll|
  sqrrll.executor = -> (sql) { ActiveRecord::Base.connection.execute(sql) }
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

Finders are the simplest. They just return the result of the `#finder` method.

```ruby
class UserFinder
  include Squirrell

  requires :id

  def finder
    User.find(@id)
  end
end
```

The `requires :id` line indicates what parameters must be passed to `find`.
An error will be raised if a required parameter is missing or if an extra parameter is passed.
The symbols in the hash are made into instance variables of the same name.

Arel finders are meant to be used in conjunction with the Arel gem.
In truth, the only requirement is that the return value of the `#arel` method respond to `:to_sql`.

```ruby
class WizardByElementAndPet
  include Squirrell

  requires :element, :pet

  def arel
    wizards = Wizard.arel_table
    wizards.where(wizards[:pet].eq(@pet))
           .where(wizards[:element].eq(@element))
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
    "SELECT heroes.id FROM heroes WHERE heroes.name = '#{@name}'"
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
# => [#<Hero:0x0987123 @name="Finn" @weapon="Grass Sword", etc...]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/squirrell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
