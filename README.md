[![Build Status](https://travis-ci.org/WizardOfOgz/memoized_inflectors.svg?branch=master)](https://travis-ci.org/WizardOfOgz/memoized_inflectors) [![Code Climate](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors/badges/gpa.svg)](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors) [![Test Coverage](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors/badges/coverage.svg)](https://codeclimate.com/github/WizardOfOgz/memoized_inflectors/coverage)

# Memoized Inflectors

This gem caches the results of ActiveSupport's String inflector methods, such as `tableize`, `constantize`, `underscore`, `pluralize`, etc. These methods are used inside Rails and are also useful for meta-programming. In the applications I analyzed the same values were being repeatedly inflected, especially across requests, and I realized that caching the results could save a lot of time and computation.


## Installation

Add `gem "memoized_inflectors"` to your Gemfile.


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

## TODO

* Back memoizations with an thread-safe LRU cache.
