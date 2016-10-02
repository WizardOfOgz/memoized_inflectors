require "spec_helper"

RSpec.describe ::MemoizedInflectors do
  context do
    subject { ::String }
    described_class.inflector_methods.each do |inflector_method|

      it "patches String##{ inflector_method }" do
        # Check that the inflector method has been successfully wrapped by verifying that its source location comes from this gem.
        expect(subject.instance_method(inflector_method).source_location.first).to match(/memoized_inflectors\.rb\z/)
      end
    end
  end
end
