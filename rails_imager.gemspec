# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rails_imager"
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["kaspernj"]
  s.date = "2014-04-10"
  s.description = "A small library to handle re-sizing, transparent edges and caching of images in Rails."
  s.email = "k@spernj.org"
  s.executables = ["rails"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "app/assets/images/rails_imager/.keep",
    "app/assets/javascripts/rails_imager/application.js",
    "app/assets/javascripts/rails_imager/images.js",
    "app/assets/stylesheets/rails_imager/application.css",
    "app/assets/stylesheets/rails_imager/images.css",
    "app/controllers/rails_imager/application_controller.rb",
    "app/controllers/rails_imager/images_controller.rb",
    "app/helpers/rails_imager/application_helper.rb",
    "app/helpers/rails_imager/images_helper.rb",
    "app/views/layouts/rails_imager/application.html.erb",
    "app/views/rails_imager/images/show.html.erb",
    "bin/rails",
    "config/routes.rb",
    "lib/rails_imager.rb",
    "lib/rails_imager/engine.rb",
    "lib/rails_imager/image_handler.rb",
    "lib/rails_imager/version.rb",
    "lib/tasks/rails_imager_tasks.rake",
    "rails_imager.gemspec",
    "test/controllers/rails_imager/images_controller_test.rb",
    "test/dummy/README.rdoc",
    "test/dummy/Rakefile",
    "test/dummy/app/assets/images/.keep",
    "test/dummy/app/assets/javascripts/application.js",
    "test/dummy/app/assets/stylesheets/application.css",
    "test/dummy/app/controllers/application_controller.rb",
    "test/dummy/app/controllers/concerns/.keep",
    "test/dummy/app/helpers/application_helper.rb",
    "test/dummy/app/mailers/.keep",
    "test/dummy/app/models/.keep",
    "test/dummy/app/models/concerns/.keep",
    "test/dummy/app/views/layouts/application.html.erb",
    "test/dummy/bin/bundle",
    "test/dummy/bin/rails",
    "test/dummy/bin/rake",
    "test/dummy/config.ru",
    "test/dummy/config/application.rb",
    "test/dummy/config/boot.rb",
    "test/dummy/config/database.yml",
    "test/dummy/config/environment.rb",
    "test/dummy/config/environments/development.rb",
    "test/dummy/config/environments/production.rb",
    "test/dummy/config/environments/test.rb",
    "test/dummy/config/initializers/backtrace_silencers.rb",
    "test/dummy/config/initializers/filter_parameter_logging.rb",
    "test/dummy/config/initializers/inflections.rb",
    "test/dummy/config/initializers/mime_types.rb",
    "test/dummy/config/initializers/secret_token.rb",
    "test/dummy/config/initializers/session_store.rb",
    "test/dummy/config/initializers/wrap_parameters.rb",
    "test/dummy/config/locales/en.yml",
    "test/dummy/config/routes.rb",
    "test/dummy/lib/assets/.keep",
    "test/dummy/log/.keep",
    "test/dummy/public/404.html",
    "test/dummy/public/422.html",
    "test/dummy/public/500.html",
    "test/dummy/public/favicon.ico",
    "test/dummy/public/test.png",
    "test/helpers/rails_imager/images_helper_test.rb",
    "test/image_handler_test.rb",
    "test/integration/navigation_test.rb",
    "test/rails_imager_test.rb",
    "test/test.png",
    "test/test_helper.rb"
  ]
  s.homepage = "http://github.com/kaspernj/rails_imager"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.7"
  s.summary = "A small library to handle re-sizing, transparent edges and caching of images in Rails."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails_imager>, [">= 0"])
      s.add_runtime_dependency(%q<knjrbfw>, [">= 0"])
      s.add_runtime_dependency(%q<rmagick>, [">= 0"])
      s.add_runtime_dependency(%q<datet>, [">= 0"])
      s.add_runtime_dependency(%q<string-cases>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<rails_imager>, [">= 0"])
      s.add_dependency(%q<knjrbfw>, [">= 0"])
      s.add_dependency(%q<rmagick>, [">= 0"])
      s.add_dependency(%q<datet>, [">= 0"])
      s.add_dependency(%q<string-cases>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails_imager>, [">= 0"])
    s.add_dependency(%q<knjrbfw>, [">= 0"])
    s.add_dependency(%q<rmagick>, [">= 0"])
    s.add_dependency(%q<datet>, [">= 0"])
    s.add_dependency(%q<string-cases>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

