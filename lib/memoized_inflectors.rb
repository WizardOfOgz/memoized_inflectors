require "active_support"
require "active_support/inflector"
require "active_support/core_ext/string"
require "active_support/core_ext/integer"

module MemoizedInflectors
  class << self
    attr_accessor :disabled
  end

  def self.cache_klass
    ::Hash
  end

  def self.caches
    @caches ||= ::Hash.new { |h,k| h[k] = cache_klass.new }
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
  #
  def self.key_for(*args)
  end

  # Clears the cache for the specified inflector. If no inflector
  # is specified, then all caches are cleared.
  def self.clear_cache(inflector = nil)
    inflector ? caches[inflector].clear : caches.clear
  end

  def self.inflector_methods
    ::ActiveSupport::Inflector.instance_methods
  end

  module StringMethods
    INFLECTORS = [
      *%i[
        camelize   classify    dasherize deconstantize
        demodulize foreign_key humanize  parameterize
        pluralize  singularize tableize  titleize
        to_param   underscore
      ].freeze,
      *DUP_UNSAFE_INFLECTORS = %i[constantize safe_constantize].freeze
    ]

    # Define an instance method for each inflector, e.g. `signularize`, `constantize`, etc.
    (INFLECTORS | ::ActiveSupport::Inflector.instance_methods).each do |inflector|
      define_method(inflector) do |*args|
        return super(*args) if ::MemoizedInflectors.disabled
        cache = ::MemoizedInflectors.cache_for(inflector)
        key = [self, *args].hash

        result =
          if cache.has_key?(key)
            cache[key]
          else
            cache[key] = super(*args)
          end

        (DUP_UNSAFE_INFLECTORS.include?(inflector) || result.nil?) ? result : result.dup
      end
    end
  end

  module IntegerMethods
    INFLECTORS = %i[ordinalize ordinal].freeze

    # Define an instance method for each inflector, e.g. `signularize`, `constantize`, etc.
    (INFLECTORS | ::ActiveSupport::Inflector.instance_methods).each do |inflector|
      define_method(inflector) do |*args|
        return super(*args) if ::MemoizedInflectors.disabled
        cache = ::MemoizedInflectors.cache_for(inflector)
        key = [self, *args].hash

        if cache.has_key?(key)
          cache[key]
        else
          cache[key] = super(*args)
        end
      end
    end
  end
end

::String.send(:prepend, ::MemoizedInflectors::StringMethods)
::Integer.send(:prepend, ::MemoizedInflectors::IntegerMethods)

