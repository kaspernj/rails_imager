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

  def self.config
    @config ||= RailsImager::Config.new

    if block_given?
      yield @config
    else
      return @config
    end
  end

  def self.require_rmagick
    return if ::Kernel.const_defined?(:RMagick)

    begin
      require "rmagick"
    rescue LoadError
      require "RMagick"
    end
  end

  def self.cache_handler
    @cache_handler ||= RailsImager::CacheHandler.new
  end
end

RailsImager.require_rmagick
