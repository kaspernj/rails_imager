$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_imager/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_imager"
  s.version     = RailsImager::VERSION
  s.authors     = ["kaspernj"]
  s.email       = ["k@spernj.org"]
  s.homepage    = "http://www.github.com/kaspernj/rails_imager"
  s.summary     = "Automatic resizing, bordering and more of images."
  s.description = "Automatic resizing, bordering and more of images."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_dependency "knjrbfw", "~> 0.0.112"
  s.add_dependency "datet", "~> 0.0.25"
  s.add_dependency "string-cases", "~> 0.0.1"

  if RUBY_ENGINE == "jruby"
    s.add_dependency "rmagick4j"
    s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
  else
    s.add_dependency "rmagick"
    s.add_development_dependency "sqlite3"
  end

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "forgery"
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_development_dependency "pry"
end
