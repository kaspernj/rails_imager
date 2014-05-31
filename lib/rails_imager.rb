require "rails/engine"
require "rails_imager/engine"
require "string-cases"
require "datet"
require "knjrbfw"

module RailsImager
  def self.const_missing(name)
    if name.to_s.end_with?("Controller")
      path = "#{File.dirname(__FILE__)}/../app/controllers/rails_imager/#{::StringCases.camel_to_snake(name)}.rb"
    elsif name.to_s.end_with?("Helper")
      path = "#{File.dirname(__FILE__)}/../app/helpers/rails_imager/#{::StringCases.camel_to_snake(name)}.rb"
    else
      path = "#{File.dirname(__FILE__)}/rails_imager/#{::StringCases.camel_to_snake(name)}.rb"
    end
    
    if File.exists?(path)
      require path
      return const_get(name) if const_defined?(name)
    end
    
    super
  end
end
