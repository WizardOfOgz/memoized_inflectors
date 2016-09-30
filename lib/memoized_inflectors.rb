require "active_support"
require "active_support/inflector"
require "active_support/core_ext/string"

module MemoizedInflectors

  DUP_UNSAFE = %i[constantize safe_constantize].freeze

  def self.prepended(klass)
    klass.class_eval do
      @memoized_inflectors = {}  # Initialize inflector cache

      # TODO: Change this to be lazy initialization *
      ::MemoizedInflectors.inflector_methods.each do |inflector|
        ivar = "@#{ inflector }"
        unless instance_variable_get(ivar)
          @memoized_inflectors[inflector] = instance_variable_set(ivar, {})
        end
      end
    end
  end

  def self.inflector_methods
    ::ActiveSupport::Inflector.instance_methods
  end

  inflector_methods.each do |inflector|
    define_method(inflector) do |*args|
      memoized_inflections = self.class.instance_variable_get("@#{ inflector }")
      key = [self, inflector, *args].hash

      result =
        if memoized_inflections.has_key?(key)
          memoized_inflections[key]
        else
          memoized_inflections[key] = super(*args)
        end

      DUP_UNSAFE.include?(inflector) ? result : result.dup
    end
  end
end

::String.send(:prepend, MemoizedInflectors)

