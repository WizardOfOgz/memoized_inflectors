require "active_support"
require "active_support/inflector"
require "active_support/core_ext/string"

module MemoizedInflectors
  INFLECTOR_METHODS = [
    :camelize, :classify, :constantize, :dasherize, :deconstantize, :demodulize, :foreign_key,
    :humanize, :inflections, :ordinal, :ordinalize, :parameterize, :pluralize, :safe_constantize,
    :singularize, :tableize, :titleize, :transliterate, :underscore
  ].freeze

  def self.prepended(klass)
    klass.class_eval do
      @memoized_inflectors = {}
      INFLECTOR_METHODS.each do |inflector_name|
        unless instance_variable_get("@#{ inflector_name }")
          @memoized_inflectors[inflector_name] = instance_variable_set("@#{ inflector_name }", {})
        end
      end
    end
  end

  INFLECTOR_METHODS.each do |inflector_name|
    define_method inflector_name do |*args|
      memoized_inflections = self.class.instance_variable_get("@#{ inflector_name }")
      key = [self, *args].hash
      memoized_inflections.has_key?(key) ? memoized_inflections[key] : memoized_inflections[key] = super(*args)
    end
  end
end

String.send(:prepend, MemoizedInflectors)
