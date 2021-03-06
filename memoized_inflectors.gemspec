$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "memoized_inflectors/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "memoized_inflectors"
  s.version     = MemoizedInflectors::VERSION
  s.authors     = ["WizardOfOgz"]
  s.email       = ["andyogzewalla@gmail.com"]

  s.homepage    = "https://github.com/WizardOfOgz/memoized_inflectors"
  s.summary     = "Memoizes ActiveSupport inflector methods."
  s.description = <<DESCRIPTION
Memoizes ActiveSupport inflector methods.
DESCRIPTION
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "LICENSE.txt", "Rakefile", "README.rdoc"]
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 4.0", "< 6"
  s.add_dependency "lru_redux",     "~> 1.1"

  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "wwtd",  "~> 1.3"
end
