$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "memoized_inflectors/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "memoized_inflectors"
  s.version     = MemoizedInflectors::VERSION
  s.authors     = ["Andy Ogzewalla"]
  s.email       = ["andyogzewalla@gmail.com"]
  s.homepage    = "https://github.com/WizardOfOgz/memoized_inflectors"
  s.summary     = "Memoizes inflected strings."
  s.description = <<DESCRIPTION
Memoizes inflected strings.
DESCRIPTION
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "activesupport", "~> 4.0"

  s.add_development_dependency "rspec", "~> 3.0"
end
