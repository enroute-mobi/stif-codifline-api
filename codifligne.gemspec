$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "codifligne/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.homepage    = "https://github.com/AF83/stif-codifline-api"
  s.name        = "codifligne"
  s.version     = Codifligne::VERSION
  s.authors     = ["Xinhui"]
  s.email       = ["xuwhisk@gmail.com"]
  s.summary     = "A wrapper for STIF Codifligne API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency "rails", '~>4.2'
  s.add_development_dependency "sqlite3", "~>1.3"
  s.add_development_dependency "awesome_print", "~> 1.6"
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec-rails", "~>3.1"
end