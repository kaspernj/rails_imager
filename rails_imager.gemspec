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

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.4"

  s.add_development_dependency "sqlite3"
end
