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
      *CLASS_INFLECTORS = %i[constantize safe_constantize].freeze  # Inflectors which return class objects need to be specially handled.
    ]

    def self.sanitize_for_key(s, inflector)
      # the class inflectors do not differentiate between names beginning with the
      # root namespace prefix (::) and those without.
      #
      if CLASS_INFLECTORS.include?(inflector)
        s.sub(/\A:*/, "")
      else
        s
      end
    end

    # Define an instance method for each inflector, e.g. `signularize`, `constantize`, etc.
    (INFLECTORS | ::ActiveSupport::Inflector.instance_methods).each do |inflector|
      define_method(inflector) do |*args|
        return super(*args) if ::MemoizedInflectors.disabled
        cache = ::MemoizedInflectors.cache_for(inflector)
        key = ::MemoizedInflectors.key_for(
          ::MemoizedInflectors::StringMethods.sanitize_for_key(self, inflector),
          *args
        )

        result =
          if cache.has_key?(key)
            cache[key]
          else
            cache[key] = super(*args)
          end

        # It is not safe to dup classes and not possible to dup nil.
        (CLASS_INFLECTORS.include?(inflector) || result.nil?) ? result : result.dup
      end
    end
  end
end

::String.send(:prepend, ::MemoizedInflectors::StringMethods)
