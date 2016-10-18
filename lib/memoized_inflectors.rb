require "active_support"
require "active_support/inflector"
require "active_support/core_ext/string"
require "active_support/core_ext/integer"
require "lru_redux"

require "memoized_inflectors/string_methods"
require "memoized_inflectors/integer_methods"

module MemoizedInflectors
  class << self
    attr_accessor :disabled
  end

  def self.new_cache_instance
    ::LruRedux::ThreadSafeCache.new(1000)  # TODO: allow users to configure the class (e.g. ThreadSafe vs non-ThreadSafe) and max size *
  end

  def self.caches
    @caches ||= ::Hash.new { |h,k| h[k] = new_cache_instance }
  end

  # Returns the cache for the given inflector. Currently inflector names must
  # be globally unique which works because there are no name collisions between
  # the String and Integer inflectors.
  #
  #=== Example
  #
  #   MemoizedInflectors.cache_for(:classify)
  def self.cache_for(inflector)
    caches[inflector]
  end

  # Returns a unique key for the given arguments.
  def self.key_for(*args)
    # Using Object#hash rather than MD5 or SHA because it works on arrays, it is faster, and it
    # also works correctly with hashes without manipulation. I.e. it is simply easier. This method
    # works since there is no intention of persisting the cache or sharing it across VM instances.
    args.hash
  end

  # Clears the cache for the specified inflector(s). If no inflector
  # is specified, then all caches are cleared.
  #
  #=== Examples
  #   MemoizedInflectors.clear_cache                           # Clears everything.
  #   MemoizedInflectors.clear_cache(:classify)                # Clear only the :classify cache.
  #   MemoizedInflectors.clear_cache(:classify, :underscore)   # Clears both the :classify and :underscore caches.
  def self.clear_cache(*inflectors)
    if inflectors.any?
      inflectors.each do |inflector|
        cache_for(inflector).clear
      end
    else
      caches.values.each(&:clear)
    end
  end

  def self.inflector_methods
    ::ActiveSupport::Inflector.instance_methods
  end
end
