module MemoizedInflectors
  module StringMethods
    # TODO: Maintain a default set of inflectors from ActiveSupport and allow users to add or remove from those. *
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
        key = ::MemoizedInflectors.key_for(self, *args)

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
end

::String.send(:prepend, ::MemoizedInflectors::StringMethods)
