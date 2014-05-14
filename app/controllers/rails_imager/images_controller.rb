# encoding: utf-8

require_dependency "rails_imager/application_controller"

class RailsImager::ImagesController < ApplicationController
  def show
    rimger = RailsImager::ImageHandler.new
    image_params = params[:image] || {}
    
    # Check for invalid parameters.
    image_params.each do |key, val|
      raise ArgumentError, "Invalid parameter: '#{key}'." unless RailsImager::ImageHandler::PARAMS_ARGS.map{ |param| param.to_s }.include?(key)
    end
    
    image_path = "#{Rails.public_path}/#{params[:id]}"
    image_path = File.realpath(image_path)
    validate_path(image_path)
    
    rimger.handle(
      :controller => self,
      :fpath => image_path,
      :params => image_params
    )
  end
  
private
  
  def validate_path(image_path)
    raise "No such file: '#{image_path}'." unless File.exists?(image_path)
    raise "Image wasn't in the public folder: '#{image_path}'." unless image_path.start_with?(Rails.public_path.to_s)
  end
end
