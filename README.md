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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/squirrell/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
