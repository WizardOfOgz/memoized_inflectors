module MemoizedInflectors
  module IntegerMethods
    INFLECTORS = %i[ordinalize ordinal].freeze

    # Define an instance method for each inflector, e.g. `signularize`, `constantize`, etc.
    (INFLECTORS | ::ActiveSupport::Inflector.instance_methods).each do |inflector|
      define_method(inflector) do |*args|
        return super(*args) if ::MemoizedInflectors.disabled
        cache = ::MemoizedInflectors.cache_for(inflector)
        key = ::MemoizedInflectors.key_for(self, *args)

        if cache.has_key?(key)
          cache[key]
        else
          cache[key] = super(*args)
        end
      end
    end
  end
end

::Integer.send(:prepend, ::MemoizedInflectors::IntegerMethods)
