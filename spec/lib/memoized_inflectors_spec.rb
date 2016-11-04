require "spec_helper"

RSpec.describe ::MemoizedInflectors do
  describe "StringMethods" do
    described_class::StringMethods::INFLECTORS.each do |inflector|
      before do
        # Clear the cache before each example
        described_class.clear_cache
      end

      it "caches values for #{ inflector }" do
        # Call the inflector method 3 times. The first time should be a cache miss, so check that two cache hits occurred.
        expect(described_class.cache_for(inflector)).to receive(:[]).exactly(2).times { String.new }
        3.times do
          "MemoizedInflectors".send(inflector)  # Note that the test string must be a valid constant name so that #constantize does not raise an error.
        end
      end
    end

    it "caches based on arguments" do
      original = "something_going/on"

      # Invoke inflector method with different options to prime the cache.
      original.camelize
      original.camelize(:lower)

      aggregate_failures do
        expect(original.camelize).to eq("SomethingGoing::On")
        expect(original.camelize(:lower)).to eq("somethingGoing::On")
      end
    end

    it "caches nil value" do
      original = "something_going/on"

      aggregate_failures do
        # camaelize(false) returns nil.
        expect(original.camelize(false)).to be_nil  # Prime cache
        expect(original.camelize(false)).to be_nil  # Cached value
      end
    end

    it "caches only up to the maximum size" do
      (1..1000).each do |i|
        "derp-#{ i }".underscore
      end

      expect(described_class.cache_for(:underscore).to_a.map(&:last)).to include("derp_1")

      "one more thing".underscore  # This should bump the first item out of the cache.

      aggregate_failures do
        cached_values = described_class.cache_for(:underscore).to_a.map(&:last)
        expect(cached_values).to_not include("derp_1")  # The first value should be removed from the cache.
        expect(cached_values).to include("derp_2")      # But the second value should still be there.
      end
    end

    describe "class inflector" do
      described_class::StringMethods::CLASS_INFLECTORS.each do |class_inflector|
        it "#{ class_inflector.inspect } works irrespective of root namespace prefix" do
          cache = described_class.cache_for(class_inflector)
          cache.clear

          expect(cache.count).to eq(0)

          "MemoizedInflectors".send(class_inflector)
          "::MemoizedInflectors".send(class_inflector)

          expect(cache.count).to eq(1)
        end
      end
    end
  end

  describe "IntegerMethods" do
    described_class::IntegerMethods::INFLECTORS.each do |inflector|
      it "caches values for #{ inflector }" do
        described_class.clear_cache
        number = rand(-1_000..1_000)

        # Call the inflector method 3 times. The first time should be a cache miss, so check that two cache hits occurred.
        expect(described_class.cache_for(inflector)).to receive(:[]).exactly(2).times { String.new }
        3.times do
          number.send(inflector)  # Note that the test string must be a valid constant name so that #constantize does not raise an error.
        end
      end
    end
  end

  describe ".clear_cache" do
    it "clears individual cache when given an inflector name" do
      "lorem_ipsum".classify.underscore

      expect(described_class.cache_for(:classify).count).to be > 0
      expect(described_class.cache_for(:underscore).count).to be > 0

      described_class.clear_cache(:classify)

      aggregate_failures do
        expect(described_class.cache_for(:classify).count).to eq(0)
        expect(described_class.cache_for(:underscore).count).to be > 0  # This cache should not have been cleared.
      end
    end

    it "clears individual caches when given multiple inflector names" do
      "lorem_ipsum".classify.underscore.titleize

      expect(described_class.cache_for(:classify).count).to be > 0
      expect(described_class.cache_for(:underscore).count).to be > 0
      expect(described_class.cache_for(:titleize).count).to be > 0

      described_class.clear_cache(:classify, :titleize)

      aggregate_failures do
        expect(described_class.cache_for(:classify).count).to eq(0)
        expect(described_class.cache_for(:underscore).count).to be > 0  # This cache should not have been cleared.
        expect(described_class.cache_for(:titleize).count).to eq(0)
      end
    end

    it "clears all caches when called without arguments" do
      "lorem_ipsum".dasherize.titleize

      expect(described_class.cache_for(:dasherize).count).to be > 0
      expect(described_class.cache_for(:titleize).count).to be > 0

      described_class.clear_cache

      aggregate_failures do
        expect(described_class.cache_for(:dasherize).count).to eq(0)
        expect(described_class.cache_for(:titleize).count).to eq(0)
      end
    end
  end
end
