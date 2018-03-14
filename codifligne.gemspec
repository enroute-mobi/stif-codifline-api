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

  s.add_dependency "nokogiri", ">=1.8.2"

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rspec"
end
