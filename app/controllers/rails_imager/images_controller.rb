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
    
    image = Magick::Image.read(image_path).first
    image = rimger.img_from_params(:image => image, :params => image_params)
    
    response.headers["Expires"] = 2.hours.from_now.httpdate
    response.headers["Last-Modified"] = File.mtime(image_path).httpdate
    
    send_data image.to_blob, :type => "image/png", :disposition => "inline"
  end
  
private
  
  def validate_path(image_path)
    raise "No such file: '#{image_path}'." unless File.exists?(image_path)
    raise "Image wasn't in the public folder: '#{image_path}'." unless image_path.start_with?(Rails.public_path.to_s)
  end
end
