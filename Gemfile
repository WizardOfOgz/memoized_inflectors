source "https://rubygems.org"

gemspec

# Run local config, if present
filename = File.expand_path("../Gemfile.local", __FILE__)
instance_eval(File.read(filename)) if File.exists?(filename)
