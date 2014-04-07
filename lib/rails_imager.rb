require "rails_imager/engine"

module RailsImager
  def self.const_missing(name)
    if name.to_s.end_with?("Controller")
      path = "#{__dir__}/../app/controllers/rails_imager/#{StringCases.camel_to_snake(name)}"
    elsif name.to_s.end_with?("Helper")
      path = "#{__dir__}/../app/helpers/rails_imager/#{StringCases.camel_to_snake(name)}"
    else
      path = "#{__dir__}/rails_imager/#{StringCases.camel_to_snake(name)}"
    end
    
    require path
    raise LoadError, "Not autoloaded: #{name}" unless const_defined?(name)
    return const_get(name)
  end
end
