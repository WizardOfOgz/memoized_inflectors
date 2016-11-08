[![Build Status](https://travis-ci.org/WizardOfOgz/memoized_inflectors.svg?branch=master)](https://travis-ci.org/WizardOfOgz/memoized_inflectors) [![Code Climate](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors/badges/gpa.svg)](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors)

For use in a Rails application you should probably use the [memoized_inflectors_rails](https://github.com/WizardOfOgz/memoized_inflectors_rails) gem instead of using memoized_inflectors directly.

# Memoized Inflectors

This gem caches the results of ActiveSupport's String inflector methods, such as `tableize`, `constantize`, `underscore`, `pluralize`, etc. These methods are used inside Rails and are also useful for meta-programming. In the applications I analyzed the same values were being repeatedly inflected, especially across requests, and I realized that caching the results could save a lot of time and computation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'memoized_inflectors'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memoized_inflectors

## Usage

After requiring `memoized_inflectors` all supported inflector method will be memoized.

### Clearing Cache

```ruby
MemoizedInflectors.clear_cache                           # Clears everything.
MemoizedInflectors.clear_cache(:classify)                # Clear only the :classify cache.
MemoizedInflectors.clear_cache(:classify, :underscore)   # Clears both the :classify and :underscore caches.
```

Calling `MemoizedInflectors.clear_cache` will clear all memoized values. The caches for each inflector method may be individually cleared by passing one or more inflector names as arguments.

### Rails Environment Reload (e.g. Development)

The solution described below is now packaged up in the [memoized_inflectors_rails](https://github.com/WizardOfOgz/memoized_inflectors_rails) gem.

If you are using Memoized Inflectors in a Ruby on Rails application then you should be aware that the memoized values of `constantize` and `safe_constantize` become stale when the environment reloads. Such reloading happens by default when the application is running in development mode and code is modified. It is recommended to place the following code in an initializer.

```ruby
Rails.application.config.to_prepare do
  MemoizedInflectors.clear_cache(:constantize, :safe_constantize)
end
```

## Constants

If `safe_constantize` returns `nil` then the value will not be cached. This is because the return value may change from `nil` to another value over time. When you remove
constants then it is recommended that you clear the cache for `:safe_constantize`.

## Benchmarks

Here is a very basic benchmark to show the performance difference between memoized invocations and non-memoized.

```ruby
> require "benchmark"
>
> number_of_iterations = 100_000
> s = "cactus"
>
> Benchmark.bm do |x|
>   MemoizedInflectors.disabled = false
>   x.report(" enabled") do
>     number_of_iterations.times { s.pluralize }
>   end
>
>   MemoizedInflectors.disabled = true
>   x.report("disabled") do
>     number_of_iterations.times { s.pluralize }
>   end
> end
              user     system      total        real
 enabled  0.150000   0.000000   0.150000 (  0.156598)
disabled  2.200000   0.010000   2.210000 (  2.206597)
```

A quick check in one of my bigger Rails projects showed that for some requests inflector methods were called over 7,000 times! In some cases using memoization made responses nearly 100ms quicker! Adding memoization was an easy way to get a nice performance boost.

## TODOs

* Allow customization of the features. E.g. let the user specify the cache store.
* Add builds for multiple ruby versions and platforms.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `wwtd --parallel` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WizardOfOgz/memoized_inflectors. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
