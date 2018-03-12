$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "codifligne/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.homepage    = "https://github.com/af83/stif-codifline-api"
  s.name        = "codifligne"
  s.version     = Codifligne::VERSION
  s.authors     = ["af83 Dev Team"]
  s.email       = ["devs@af83.com"]
  s.summary     = "A wrapper for STIF Codifligne/iLICO API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.markdown"]
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency "nokogiri", ">=1.7.2"

  s.add_development_dependency "awesome_print", "~> 1.6"
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "webmock", "~> 1.22"
  s.add_development_dependency "rspec", '~> 3.4'
end
