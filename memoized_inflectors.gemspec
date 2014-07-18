$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "memoized_inflectors/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "memoized_inflectors"
  s.version     = MemoizedInflectors::VERSION
  s.authors     = ["Andy Ogzewalla"]
  s.email       = ["andyogzewalla@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Memoizes inflected strings."
  s.description = <<DESCRIPTION
Memoizes inflected strings.
DESCRIPTION
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0"
end
